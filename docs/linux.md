# Linux Setup (from scratch)

How to take a fresh Linux install to a working dev environment with this repo. Covers Ubuntu/Debian, Fedora (non-Atomic), Arch, cloud VMs, and servers.

> On **WSL** (Windows Subsystem for Linux)? Use [wsl.md](wsl.md) - the flow is the same but there are Windows-specific prerequisites and gotchas.
>
> On an **immutable Fedora Atomic** desktop (Silverblue/Kinoite/COSMIC Atomic)? Use [fedora-atomic.md](fedora-atomic.md) - the host is provisioned differently (`rpm-ostree`, Quadlet), then this same flow runs on top.

## What you end up with

- Homebrew (under `/home/linuxbrew`) with every CLI tool in `brew/linux/dot_Brewfile.tmpl`.
- Pinned language runtimes (python, go, rust, node) via mise.
- Shell (zsh/bash), prompt (starship), editor (neovim), tmux, and aliases configured in `~`.

No GUI casks - the Linux Brewfile is CLI-only. GUI apps on Linux come from your distro or Flatpak, not this repo.

## Prerequisites

Homebrew on Linux needs a compiler toolchain and a few base packages. Install them for your distro before bootstrapping:

**Ubuntu / Debian**
```sh
sudo apt update
sudo apt install -y build-essential curl file git procps
```

**Fedora (non-Atomic)**
```sh
sudo dnf install -y @development-tools curl file git procps-ng
```

**Arch**
```sh
sudo pacman -S --needed base-devel curl file git procps-ng
```

That is all you install by hand. chezmoi, Homebrew, and mise come from the bootstrap.

## Bootstrap

### 1. Install chezmoi and apply the dotfiles

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply T-Py-T
```

This one command:

- Installs the `chezmoi` binary to `~/.local/bin`.
- Clones this repo to `~/.local/share/chezmoi`.
- Runs `run_once_before_setup` - installs Homebrew to `/home/linuxbrew` if missing (`brew doctor` output is informational and never aborts).
- Applies every `dot_*` file to `~` (zsh, bash, tmux, `~/.config/*`, and the global `~/mise.toml`).
- Runs `run_10_homebrew` - `brew bundle` against `brew/linux/dot_Brewfile.tmpl`. Selection is by `uname -s`, so every non-Atomic distro uses the same Linux Brewfile.

### 2. Install the pinned runtimes

```sh
mise install
```

Reads `~/mise.toml` and installs python, go, rust, and node at the pinned versions.

### 3. Start a fresh shell

Open a new shell (or `exec zsh` / `exec bash`) so mise activation, starship, and the modular shell config load.

## Verify

```sh
brew bundle check --file ~/.local/share/chezmoi/brew/linux/dot_Brewfile.tmpl   # "dependencies are satisfied"
mise current            # python/go/rust/node at pinned versions
which go node python    # all resolve under ~/.local/share/mise/installs/...
chezmoi status          # empty = everything applied
```

## Keeping it current

```sh
chezmoi update          # pull latest from the repo and re-apply (re-runs brew bundle)
brew upgrade            # upgrade installed formulae
mise upgrade            # bump runtimes within the pins
```

## Notes by environment

| Environment | Notes |
|---|---|
| Cloud VM (EC2, Linode, DO) | Fine for long-lived dev VMs. For throwaway VMs that live hours, a one-off `brew install ripgrep fzf neovim` is faster than the full bootstrap. |
| Headless server | Works with no GUI - it is just chezmoi + Brewfile + mise. SSH in and bootstrap. |
| Existing install you don't want to replace | This repo layers on top of whatever is there; it does not manage the OS. |

## What is NOT covered

- **Display server / window manager, GPU drivers** - distro- and hardware-specific, out of scope.
- **System services** - on Atomic, use the Quadlet pattern in [fedora-atomic.md](fedora-atomic.md); on traditional Linux, write and install the systemd unit yourself.
- **GUI apps** - install via your distro package manager or Flatpak.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `brew` not found after bootstrap | Start a new shell. The `00-homebrew` shell module runs `brew shellenv`; a stale shell predates it. |
| `go`/`node` resolve to Homebrew, not the pinned version | Start a new shell. mise activates last so its shims win. |
| `tree-sitter-cli` install fails inside nvim | mise's node must be active. Open a new interactive shell after `mise install`, then relaunch nvim. |
| A third-party tap is "not trusted" | The Brewfile pins `trusted: true`; make sure you are on the latest repo (`chezmoi update`). |

See also: [Runtime vs tool strategy](../README.md#runtime-vs-tool-strategy) for how mise and Homebrew divide responsibilities.
