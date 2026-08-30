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

- [Agent stack](agent-stack.md) - verified coordination architecture, pinned runtimes, privacy defaults, multi-host limits, and upgrade procedure.
- [findings/git-commit-trailers.md](findings/git-commit-trailers.md) - if `Co-authored-by` lines appear without you typing them.
- [findings/neovim-migration.md](findings/neovim-migration.md) - the neovim vim.pack migration notes.
- [Runtime vs tool strategy](../README.md#runtime-vs-tool-strategy) - how mise (runtimes) and Homebrew (tools) divide responsibilities. Read before changing package management.

## The bootstrap flow (all platforms)

Every platform runs the same three steps; only the prerequisites differ.

```
0. Platform-specific prereqs        (see the per-OS guide)
1. sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
   - installs the chezmoi binary (-b is required; the default is ./bin)
2. chezmoi init --apply T-Py-T/chezmoi-dotfiles
   - full owner/repo: the bare-username form hits a different, private repo
   - clones the repo to ~/.local/share/chezmoi
   - run_once_before_setup   installs Homebrew (brew doctor is informational)
   - applies all dot_ files to ~ (incl. global ~/mise.toml)
   - run_10_homebrew         runs brew bundle on the right Brewfile,
                             then brew bundle cleanup --force
   - run_after_20_agent_tools installs verified Beads/OMP/Pi/Hermes releases
3. new shell                        loads brew shellenv, mise, starship
4. mise install                     installs the pinned runtimes
5. agent-stack-doctor              verifies the portable agent layer
```

Step 3 comes before step 4 on purpose: mise is installed by `brew bundle`, so it is not
on `PATH` in the shell that ran the bootstrap.

## How the Brewfile is chosen

`scripts/run_10_homebrew` selects the Brewfile by environment:

| Detection | Brewfile |
|---|---|
| `DEVCONTAINER=1` or `/.dockerenv` exists | `brew/devcontainer/dot_Brewfile.tmpl` |
| `uname -s` = `Linux` and WSL detected (`/proc/version` or `$WSL_DISTRO_NAME`) | `brew/linux/dot_Brewfile-wsl.tmpl` |
| `uname -s` = `Linux` (Fedora Atomic, regular distros) | `brew/linux/dot_Brewfile.tmpl` |
| `uname -s` = `Darwin` | `brew/macos/dot_Brewfile.tmpl` |

The base Linux Brewfile covers Fedora Atomic and regular Linux hosts. WSL uses a superset Brewfile with additional terminal tools, agents, network utilities, and the Agave Nerd Font. Atomic-specific concerns (`rpm-ostree` packages, Quadlet units) live in the Fedora Atomic guide, not a separate Brewfile.

The WSL font guide covers the required Linux-side font installation and the separate Windows Terminal font configuration: [Nerd Fonts on WSL](nerd-fonts-wsl.md).

## Conventions

- One setup guide per OS type, self-contained. Duplication beats indirection.
- `findings/` holds research notes and troubleshooting writeups, dated where useful.
