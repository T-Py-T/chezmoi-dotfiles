# docs

Setup and reference documentation for this dotfiles repo.

## Setup guides (from scratch)

Pick the one for your machine:

- [macOS](macos.md) - Apple Silicon MacBook. GUI apps via Homebrew casks.
- [Linux](linux.md) - Ubuntu/Debian, Fedora, Arch, cloud VMs, servers.
- [WSL](wsl.md) - Windows Subsystem for Linux (Windows-specific prereqs + the Linux flow).

## Advanced / other environments

- [Fedora Atomic](fedora-atomic.md) - immutable desktop (Silverblue/Kinoite/COSMIC Atomic): `rpm-ostree`, Flatpak, and Podman Quadlet layers, then the standard bootstrap on top.
- [Devcontainer](devcontainer.md) - minimal containerized environment for per-project devcontainers and DevPod.

## Reference

- [findings/git-commit-trailers.md](findings/git-commit-trailers.md) - if `Co-authored-by` lines appear without you typing them.
- [findings/neovim-migration.md](findings/neovim-migration.md) - the neovim vim.pack migration notes.
- [Runtime vs tool strategy](../README.md#runtime-vs-tool-strategy) - how mise (runtimes) and Homebrew (tools) divide responsibilities. Read before changing package management.

## The bootstrap flow (all platforms)

Every platform runs the same three steps; only the prerequisites differ.

```
0. Platform-specific prereqs        (see the per-OS guide)
1. sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply T-Py-T
   - installs chezmoi, clones the repo to ~/.local/share/chezmoi
   - run_once_before_setup   installs Homebrew (brew doctor is informational)
   - applies all dot_ files to ~ (incl. global ~/mise.toml)
   - run_10_homebrew         runs brew bundle on the right Brewfile
2. mise install                     installs the pinned runtimes
3. new shell                        loads mise, starship, modular shell config
```

## How the Brewfile is chosen

`scripts/run_10_homebrew` selects the Brewfile by environment:

| Detection | Brewfile |
|---|---|
| `DEVCONTAINER=1` or `/.dockerenv` exists | `brew/devcontainer/dot_Brewfile.tmpl` |
| `uname -s` = `Linux` (Atomic, WSL, any distro) | `brew/linux/dot_Brewfile.tmpl` |
| `uname -s` = `Darwin` | `brew/macos/dot_Brewfile.tmpl` |

There is intentionally one Linux Brewfile for all distros. Atomic-specific concerns (`rpm-ostree` packages, Quadlet units) live in the Fedora Atomic guide, not a separate Brewfile.

## Conventions

- One setup guide per OS type, self-contained. Duplication beats indirection.
- `findings/` holds research notes and troubleshooting writeups, dated where useful.
