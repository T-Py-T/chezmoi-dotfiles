# Portable development environment

[![Validate](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/validate.yml/badge.svg?branch=main)](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/validate.yml)
[![Neovim Health](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/nvim-health.yml/badge.svg?branch=main)](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/nvim-health.yml)


My cross-platform shell and developer-tool configuration, managed with
[chezmoi](https://www.chezmoi.io/). A single source tree configures macOS,
Linux, WSL, Fedora Atomic, and development containers while keeping
machine-specific and secret state out of Git.

The repository is for developers who want a repeatable workstation bootstrap
without replacing the host operating system. It installs the appropriate tool
set, pins language runtimes, applies shell and editor configuration, and checks
that the resulting environment is usable.

## What it manages

| Layer | Managed here |
| --- | --- |
| Shell | Zsh, Bash, aliases, Starship, tmux, and common environment setup |
| Editor | Neovim configuration and a headless health check |
| Tools | Platform-specific Homebrew bundles for CLI tools, apps, and extensions |
| Runtimes | Python, Go, Rust, and Node versions pinned with `mise` |
| Agent tooling | Checksum-pinned runtimes, a shared coordination skill, and non-secret diagnostics |

Chezmoi renders `dot_*` and `dot_config/` into the home directory. The bootstrap
scripts select the correct Brewfile for the detected platform, then install the
portable agent tools under `~/.local`. Full application settings and all
credentials remain outside this repository.

## Platform guides

- [macOS](docs/macos.md)
- [Linux](docs/linux.md)
- [Windows Subsystem for Linux](docs/wsl.md)
- [Fedora Atomic](docs/fedora-atomic.md)
- [Development containers](docs/devcontainer.md)

## Quick start

Read the guide for your platform first. Once its prerequisites are installed:

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
a different repository. Review pending changes before applying them to an
existing workstation:

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

The dotfiles intentionally divide ownership between tools: Homebrew installs
ordinary applications, `mise` selects language runtimes, and the agent installer
owns its checksum-pinned binaries. The exact PATH and update rules are documented
in [Runtime and tool ownership](docs/runtime-tooling.md).

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
workflows do not run on pushes, schedules, or manual dispatches.

## Repository layout

| Path | Purpose |
| --- | --- |
| `dot_*`, `dot_config/` | Files materialized into the home directory |
| `brew/` | Brewfiles for macOS, Linux, and development containers |
| `mise.toml` | Pinned language runtimes |
| `scripts/` | Bootstrap, update, and validation helpers |
| `dot_local/bin/` | Portable diagnostics and coordination commands |
| `dot_agents/skills/` | Shared, non-secret agent instructions |
| `docs/` | Platform setup and design notes |
| `.chezmoiignore` | Files that must remain in the source repository only |

## Privacy and safety

This repository does not track tokens, sessions, SSH keys, agent databases,
caches, or memory stores. Review the rendered diff from `chezmoi update
--dry-run --verbose` before applying changes to a machine with local
customizations.

## License and inspiration

Repository-specific configuration and documentation are available under the
[MIT License](LICENSE).

The structure draws inspiration from
[Mischa van den Burg](https://mischavandenburg.com/),
[mloberg/dotfiles](https://github.com/mloberg/dotfiles),
[Dreams of Autonomy](https://www.youtube.com/watch?v=9U8LCjuQzdc), and
[Josean Martinez](https://www.youtube.com/@joseanmartinez).
