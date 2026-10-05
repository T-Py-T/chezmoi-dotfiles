# chezmoi-dotfiles

[![Validate](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/validate.yml/badge.svg?branch=main)](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/validate.yml)
[![Neovim Health](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/nvim-health.yml/badge.svg?branch=main)](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/nvim-health.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**One command from a fresh machine to a familiar workstation, on macOS, Linux,
WSL, Fedora Atomic and dev containers.**

A [chezmoi](https://www.chezmoi.io/) source tree for Zsh, Bash, Starship,
tmux and Neovim, plus platform Brewfiles and pinned language runtimes.
Machine-specific state and every secret stay out of Git, and the host OS
stays yours: this repo configures your workstation without replacing the OS.

[Quick start](#quick-start) ·
[Preview safely](#preview-before-you-apply) ·
[What you get](#what-you-get) ·
[Platform guides](#platform-guides) ·
[Contributing](#contributing)

## Why use it

- **One source tree, five platforms.** The bootstrap script detects the
  platform and picks the matching Brewfile (`brew/macos`, `brew/linux` or
  `brew/devcontainer`).
- **Reproducible runtimes.** `mise` pins Python 3.14.3, Go 1.25.7,
  Rust 1.93.0 and Node 22.12.0.
- **Clear ownership.** Homebrew installs applications, `mise` owns language
  runtimes, and the agent-tool installer owns its checksum-pinned binaries.
  See [Runtime and tool ownership](docs/runtime-tooling.md).
- **Checked on every pull request.** pre-commit (TOML/JSON/YAML, ShellCheck,
  StyLua), `mise config ls`, `starship explain`, and a headless Neovim health
  check.
- **Secrets stay out.** No tokens, sessions, SSH keys, agent databases,
  caches or memory stores are tracked.

## What you get

| Layer | Managed here |
| --- | --- |
| Shell | Zsh and Bash, shared aliases, Starship prompt, tmux, fzf, zoxide, eza, direnv |
| Editor | Neovim config with a lockfile and a headless health check |
| Tools | Per-platform Homebrew bundles for CLI tools, apps and extensions |
| Runtimes | Python, Go, Rust and Node pinned with `mise` |
| Agent tooling | Checksum-pinned CLI tools under `~/.local`, a shared coordination skill, and `agent-stack-doctor` for non-secret diagnostics |

There are no screenshots in the repository. The preview below shows exactly
what chezmoi would write.

## Quick start

> Not run as part of this README update. It writes to your home directory, so
> [preview it first](#preview-before-you-apply).

Read the [guide for your platform](#platform-guides), install its
prerequisites, then:

```sh
mkdir -p ~/.local/bin
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
chezmoi init --apply T-Py-T/chezmoi-dotfiles
exec "$SHELL" -l
mise install
agent-stack-doctor
```

Use the full `T-Py-T/chezmoi-dotfiles` name. The bare account name resolves to
a different repository.

## Preview before you apply

chezmoi can render everything into a throwaway directory, so you can inspect
the result without touching your real home directory or chezmoi config:

```sh
git clone https://github.com/T-Py-T/chezmoi-dotfiles.git
cd chezmoi-dotfiles
tmp="$(mktemp -d)"
cz() {
  chezmoi --source "$PWD" --destination "$tmp/home" \
    --config "$tmp/chezmoi.toml" --persistent-state "$tmp/state.boltdb" \
    --cache "$tmp/cache" "$@"
}
cz managed --include=files          # list every file it would write
cz apply --dry-run --verbose --exclude=scripts
```

Run with chezmoi 2.71.0 on macOS, this listed 33 managed files, including
`.zshrc`, `.config/nvim/init.lua`, `.config/starship.toml`, `.tmux.conf` and
`.local/bin/agent-stack-doctor`. The dry run exited cleanly and left the
temporary destination empty. `--exclude=scripts` skips the four bootstrap
scripts (Homebrew bundle, agent tools, pre-commit hooks, first-run setup),
because those install software.

On a machine that's already set up, review incoming changes the same way:

```sh
chezmoi update --dry-run --verbose
chezmoi update
```

## Update a configured machine

```sh
chezmoi update
brew upgrade
mise upgrade
agent-stack-doctor
```

## Platform guides

- [macOS](docs/macos.md)
- [Linux](docs/linux.md)
- [Windows Subsystem for Linux](docs/wsl.md)
- [Fedora Atomic](docs/fedora-atomic.md)
- [Development containers](docs/devcontainer.md)

Design notes: [Runtime and tool ownership](docs/runtime-tooling.md) and
[Agent tool stack](docs/agent-stack.md).

## Validate a change

Run the repository checks before applying a change to a workstation:

```sh
pre-commit run --all-files --show-diff-on-failure
```

For Neovim changes, also run:

```sh
bash scripts/check-nvim-health.sh
```

Pull requests run configuration validation and the Neovim health check. The
workflows don't run on pushes, schedules or manual dispatches.

## Repository layout

| Path | Purpose |
| --- | --- |
| `dot_*`, `dot_config/` | Files materialized into the home directory |
| `brew/` | Brewfiles for macOS, Linux and development containers |
| `mise.toml` | Pinned language runtimes |
| `scripts/` | Bootstrap, update and validation helpers |
| `dot_local/bin/` | Portable diagnostics and coordination commands |
| `dot_agents/skills/` | Shared, non-secret agent instructions |
| `docs/` | Platform setup and design notes |
| `.chezmoiignore` | Files that stay in the source repository only |

Known rough edge: `.chezmoiignore` doesn't currently exclude
`CONTRIBUTING.md`, `LICENSE` or `SECURITY.md`, so the preview shows them as
home-directory targets.

## Privacy and safety

This repository doesn't track tokens, sessions, SSH keys, agent databases,
caches or memory stores. Full application settings and all credentials stay on
the machine. Review the rendered diff from `chezmoi update --dry-run --verbose`
before applying changes to a machine with local customizations. Report
security issues as described in [SECURITY.md](SECURITY.md), not in public
issues.

## Contributing

Fixes and platform improvements are welcome. See
[CONTRIBUTING.md](CONTRIBUTING.md), keep secrets and machine-specific values
out of commits, and run the checks in [Validate a change](#validate-a-change)
before opening a pull request.

## License and inspiration

Repository-specific configuration and documentation are available under the
[MIT License](LICENSE).

The structure draws inspiration from
[Mischa van den Burg](https://mischavandenburg.com/),
[mloberg/dotfiles](https://github.com/mloberg/dotfiles),
[Dreams of Autonomy](https://www.youtube.com/watch?v=9U8LCjuQzdc), and
[Josean Martinez](https://www.youtube.com/@joseanmartinez).
