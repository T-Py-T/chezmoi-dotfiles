# Linux Setup (from scratch)

How to take a fresh Linux install to a working dev environment with this repo. Covers Ubuntu/Debian, Fedora (non-Atomic), Arch, cloud VMs, and servers.

> On **WSL** (Windows Subsystem for Linux)? Use [wsl.md](wsl.md) - the flow is the same but there are Windows-specific prerequisites and gotchas.
>
> On an **immutable Fedora Atomic** desktop (Silverblue/Kinoite/COSMIC Atomic)? Use [fedora-atomic.md](fedora-atomic.md) - the host is provisioned differently (`rpm-ostree`, Quadlet), then this same flow runs on top.

## What you end up with

- Homebrew (under `/home/linuxbrew`) with every CLI tool in `brew/linux/dot_Brewfile.tmpl`.
- Pinned language runtimes (python, go, rust, node) via mise.
- Shell (zsh/bash), prompt (starship), editor (neovim), tmux, and aliases configured in `~`.
- Pinned Beads, OMP, Pi, and Hermes runtimes plus Dolt and the shared agent-coordination skill.

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

WSL is the intentional exception at the Brewfile-selection layer: `scripts/run_10_homebrew` detects WSL and selects `brew/linux/dot_Brewfile-wsl.tmpl`, which adds terminal tooling and the Agave Nerd Font. See [wsl.md](wsl.md) and [nerd-fonts-wsl.md](nerd-fonts-wsl.md) for the Windows-specific setup.

## Bootstrap

### 1. Install chezmoi

```sh
mkdir -p ~/.local/bin
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
```

`-b` is required: the installer's default install directory is `./bin`, relative to the
current directory.

### 2. Clone and apply the dotfiles

```sh
chezmoi init --apply T-Py-T/chezmoi-dotfiles
```

Use the full `owner/repo`. The bare-username shorthand (`chezmoi init --apply T-Py-T`)
expands to `github.com/T-Py-T/dotfiles`, a different and private repo.

This one command:

- Clones this repo to `~/.local/share/chezmoi`.
- Runs `run_once_before_setup` - installs Homebrew to `/home/linuxbrew` if missing (`brew doctor` output is informational and never aborts).
- Applies every `dot_*` file to `~` (zsh, bash, tmux, `~/.config/*`, and the global `~/mise.toml`).
- Runs `run_10_homebrew` - `brew bundle` against `brew/linux/dot_Brewfile.tmpl`, then `brew bundle cleanup --force`, which uninstalls any formula not listed there. Selection is by `uname -s`, so every non-Atomic distro uses the same Linux Brewfile.
- Runs `run_after_20_agent_tools` - installs checksum-verified agent runtimes and merges only the portable Hermes worktree and skill settings.

### 3. Start a fresh shell

```sh
exec bash
```

Required before the next step: mise is installed by `brew bundle`, so it is not on
`PATH` in the shell that ran the bootstrap. A new shell loads `brew shellenv`, then mise
activation, then starship. Use `exec zsh` only if zsh is installed - it is not in the
Linux Brewfile.

### 4. Install the pinned runtimes

```sh
mise install
```

Reads `~/mise.toml` and installs python, go, rust, and node at the pinned versions.

## Verify

```sh
brew bundle check --file ~/.local/share/chezmoi/brew/linux/dot_Brewfile.tmpl   # "dependencies are satisfied"
mise current            # python/go/rust/node at pinned versions
which go node python    # all resolve under ~/.local/share/mise/installs/...
chezmoi status          # only ' R scripts/10_homebrew' and ' R scripts/20_agent_tools'
agent-stack-doctor      # pinned runtimes, shared skill, and isolation checks
```

`chezmoi status` is never empty: the two `run_` scripts execute on every apply, so
chezmoi always lists them as `R`. Only `M`/`A`/`D` lines on `dot_*` targets mean
something is unapplied.

## Keeping it current

```sh
chezmoi update          # pull latest from the repo and re-apply (re-runs brew bundle)
brew upgrade            # upgrade installed formulae
mise upgrade            # bump runtimes within the pins
agent-stack-doctor
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
