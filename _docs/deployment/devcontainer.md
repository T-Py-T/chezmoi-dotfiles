# Devcontainer Deployment

Minimal containerized environment used by per-project devcontainers and DevPod workspaces. Optimized for terminal + nvim + git workflow inside a container.

## What this is for

Per-project dev environments where:
- The host should not be polluted with the project's tools.
- The same environment must work on macOS, Linux, and CI runners.
- A new contributor (or new machine) gets a working setup in one `devpod up` or `code .` + "Reopen in Container".

The 6 currently-managed devcontainers are listed in `workspace-configs/README.md`.

## What is devcontainer-specific

The detection happens in `scripts/run_10_homebrew`:

```
if [ "${DEVCONTAINER:-0}" = "1" ] || [ -f /.dockerenv ]; then
  brew bundle --file "${source_dir}/brew/devcontainer/dot_Brewfile.tmpl"
  exit 0
fi
```

Two signals:
- `DEVCONTAINER=1` — set by `devcontainer.json` via the `containerEnv` field.
- `/.dockerenv` — present in any container, fallback for setups that don't set the env var.

When either is true, the **devcontainer-only Brewfile** runs. This is a minimal subset:
- nvim + treesitter + luarocks (editor)
- ripgrep, fd, fzf (nvim navigation)
- git, lazygit (version control)
- bat, eza, htop, jq, tmux, wget, zoxide (terminal essentials)
- k9s, kubectx (kubernetes — even in containers, shells often need to talk to a cluster)
- pre-commit, shellcheck, starship (shell tooling)

**Not included:** GUI tools, casks, cloud CLIs, language runtimes (those come from the project's own image).

## Per-project devcontainer.json setup

Each project's `.devcontainer/devcontainer.json` should:

1. Set `DEVCONTAINER=1` so this repo's scripts pick the right Brewfile:
   ```json
   "containerEnv": {
     "DEVCONTAINER": "1"
   }
   ```

2. Mount or clone this dotfiles repo, then run chezmoi. Two patterns:

   **Pattern A — chezmoi runs at container creation (recommended):**
   ```json
   "postCreateCommand": "sh -c \"$(curl -fsLS get.chezmoi.io)\" -- init --apply <github-username>"
   ```
   Container is fully provisioned on creation. Slower first start, fast every subsequent start.

   **Pattern B — VS Code dotfiles integration:**
   In VS Code settings: `dotfiles.repository = "<github-username>/chezmoi-dotfiles"`. VS Code handles the clone + apply on container start. Works for VS Code only — DevPod and other tools won't pick this up.

Pattern A is preferred because it works regardless of the IDE.

## DevPod-specific notes

`workspace-configs/Makefile` manages 6 DevPod workspaces. DevPod injects its own user setup (SSH keys, agent forwarding) and then runs `postCreateCommand`.

For this repo specifically, `scripts/devpod-up.sh <name>` does a full clean rebuild. Use it when the Dockerfile or startup.sh changes and a warm workspace would skip the updates.

**Live-verified end-to-end** (April 2026, post-vim.pack migration):
- Fresh rebuild: ~4.5 min total (image build + apt + mise install + Homebrew install + brew bundle + nvim vim.pack install + PackChanged build hook).
- `scripts/check-nvim-health.sh` inside the container: `OK:132 WARNINGS:27 ERRORS:0`.
- All 19 vim.pack plugins clone to `~/.local/share/nvim/site/pack/core/opt/`.
- `PackChanged` autocmd fires and compiles `telescope-fzf-native.nvim/build/libfzf.so` (arm64 Linux).
- Tree-sitter parsers bundled with nvim (`c, lua, markdown, markdown_inline, query, vim, vimdoc`) report `OK`. Extras in `init.lua` (`bash, diff, html, luadoc`) install on first nvim launch via the nvim-treesitter async installer — needs `tree-sitter-cli` on PATH.

### Expected warnings (these are not regressions)

`checkhealth` reports 27 warnings in the headless devcontainer test. All are benign:

- `blink_cmp_fuzzy lib is not downloaded/built` — we explicitly use `fuzzy = { implementation = 'lua' }` in init.lua.
- `Ruby/Perl provider: disabled` — `vim.g.loaded_ruby_provider = 0` and same for perl in init.lua.
- `Go/cargo/npm/node/Python neovim module not available` — mise is not activated in `bash -lc` (non-interactive login shell). An interactive shell (`zsh` as configured, or `bash -i`) activates mise and these warnings go away.
- `stylua/gopls/pyright-langserver/lua-language-server not executable` — Mason installs these on first nvim launch, but the headless health check runs before Mason's async installer has finished.
- `vim.ui.open: no handler found` — no `xdg-open` in the minimal Ubuntu base. Only matters for opening links/files from nvim. Install `xdg-utils` via apt if needed.
- `No clipboard tool found` — no `xclip`/`wl-clipboard` in the container. `unnamedplus` clipboard register will no-op.
- `opts.jump.float is deprecated. Feature will be removed in Nvim 0.14` — inherited from kickstart, works on 0.12/0.13. Revisit before 0.14.

## What is NOT in the devcontainer Brewfile

Intentionally excluded:

| Thing | Why |
|---|---|
| Cloud CLIs (`aws-sam-cli`, `terraform`, `vault`) | Per-project. Add to the project's own `Dockerfile` or `devcontainer.json` features. |
| Language runtimes | Project-specific. Comes from the project's base image or its own mise config. |
| GUI casks | Containers have no GUI. |
| `chezmoi` itself | Bootstrapped in `postCreateCommand`. |
| `mise` | Comes from the project's setup, not from this Brewfile. Different projects pin different versions. |

## Common gotchas

| Issue | Cause | Fix |
|---|---|---|
| `brew doctor` fails inside container | Detects unusual environment | `scripts/run_once_before_setup.tmpl` skips `brew doctor` when `DEVCONTAINER=1` or `/.dockerenv` exists. If still failing, confirm one of those signals is set. |
| chezmoi tries to install macOS-only casks | `uname -s` reporting wrong value, or DEVCONTAINER not set | Confirm `echo $DEVCONTAINER` returns `1` inside the container. If not, the `containerEnv` block in `devcontainer.json` is missing or wrong. |
| Telescope `live_grep` finds nothing | `ripgrep` not installed | The devcontainer Brewfile includes ripgrep. If missing, `brew bundle` did not complete — check `postStartCommand` logs. |
| nvim treesitter parsers fail to compile | Wrong tree-sitter formula | As of 2025 the Homebrew `tree-sitter` formula only installs `libtree-sitter.so` (library). The CLI is now `brew "tree-sitter-cli"`. This repo's Brewfiles already use the CLI formula; if you vendor a different Brewfile, change it. `dot_zshrc` also has an npm fallback for shells where brew isn't present. |
| `checkhealth` reports locale / UTF-8 errors | Ubuntu jammy base ships without LANG set | The Dockerfile sets `ENV LANG=C.UTF-8 LC_ALL=C.UTF-8`. If you strip those for a slimmer image, checkhealth will fail with `ERROR Locale does not support UTF-8`. |
| `checkhealth` reports `{ "infocmp", "-L" }` failure | TERM empty or `dumb` in headless exec | The Dockerfile sets `ENV TERM=xterm-256color`. For containers where `docker exec` overrides TERM, pass `-e TERM=xterm-256color`. |
| nvim 0.11 is installed, vim.pack missing | Dockerfile pinned an older nvim release | `.devcontainer/Dockerfile` pins nvim via `ARG NVIM_VERSION=v0.12.1`. Rebuild after bumping. The new init.lua has a version guard at the top and will error with a clear message on nvim < 0.12. |
| `nvim +LazySync` fails | lazy.nvim removed as part of the 0.12 migration | `.devcontainer/startup.sh` now boots `nvim --headless -c "qa"` which triggers vim.pack's built-in install. `+LazySync` should not be used anywhere. |
| Container build is slow on every start | `postStartCommand` runs every time | DevPod caches by `containerEnv` hash. `postStartCommand` runs on every start by design (as opposed to `postCreateCommand`). If the work should only happen once, move it to `postCreateCommand`. |

## Updating an existing devcontainer

```
chezmoi update    # pulls latest from this repo and re-applies
brew update && brew upgrade
```

Container restart not required.

## Why the devcontainer Brewfile is separate from `brew/linux/`

Two reasons:
1. The Linux laptop Brewfile assumes a long-lived workstation (cloud CLIs, kubernetes, security tooling). A devcontainer is ephemeral.
2. Container images should be small. Adding ~30 unused tools to every dev container would balloon image size with zero benefit.

If a tool is genuinely needed in *both* contexts, list it in both files. Duplication beats indirection.
