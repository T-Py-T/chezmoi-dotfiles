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

Behavior already verified:
- `DEVCONTAINER=1` is preserved in the DevPod-built container.
- Chezmoi templates that branch on `chezmoi.os` correctly identify Linux.
- `brew bundle` against the devcontainer Brewfile completes in ~2–3 minutes on a warm cache.

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
| `brew doctor` fails inside container | Detects unusual environment | The `run_once_before_setup.tmpl` script skips `brew doctor` when `DEVCONTAINER=1` or `/.dockerenv` exists. If still failing, check that one of those signals is set. |
| chezmoi tries to install macOS-only casks | `uname -s` reporting wrong value, or DEVCONTAINER not set | Confirm `echo $DEVCONTAINER` returns `1` inside the container. If not, the `containerEnv` block in `devcontainer.json` is missing or wrong. |
| Telescope `live_grep` finds nothing | `ripgrep` not installed | The devcontainer Brewfile includes ripgrep. If missing, `brew bundle` did not complete — check `postCreateCommand` logs. |
| nvim plugins fail to compile | tree-sitter CLI missing | Brewfile includes `tree-sitter`. The `dot_zshrc` also installs `tree-sitter-cli` via npm if both nvim and npm are present. Both should not be needed, but redundancy is intentional. |
| Container build is slow on every start | `postCreateCommand` runs every time | DevPod caches by `containerEnv` hash. If the `postCreateCommand` is hashed correctly it should only re-run on first build. Verify with `devpod logs <workspace>`. |

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
