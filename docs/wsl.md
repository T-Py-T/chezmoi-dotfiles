# WSL Setup (from scratch)

How to take a fresh Windows machine to a working Linux dev environment with this repo, running under WSL2 (Windows Subsystem for Linux).

WSL reports as Linux (`uname -s` = `Linux`, chezmoi `.os` = `linux`), so it uses the Linux Brewfile and the same bootstrap as any other distro. What is different is getting WSL itself set up and a few Windows-integration gotchas.

## What you end up with

- A WSL2 Ubuntu distro with Homebrew (under `/home/linuxbrew`) and every CLI tool in `brew/linux/dot_Brewfile.tmpl`.
- Pinned language runtimes (python, go, rust, node) via mise.
- Shell (zsh/bash), prompt (starship), editor (neovim), tmux, and aliases configured in `~`.

## Prerequisites

### 1. Install WSL2 and Ubuntu

From an elevated **PowerShell** (Run as Administrator) on Windows:

```powershell
wsl --install
```

This enables WSL2 and installs Ubuntu by default. Reboot if prompted, then launch **Ubuntu** from the Start menu and create your Linux username and password when asked.

Confirm you are on WSL2 (not WSL1):
```powershell
wsl --list --verbose
```
The `VERSION` column should read `2`. If it says `1`, convert it: `wsl --set-version Ubuntu 2`.

### 2. Install the Homebrew base packages

Inside the Ubuntu shell:

```sh
sudo apt update
sudo apt install -y build-essential curl file git procps
```

That is all you install by hand. chezmoi, Homebrew, and mise come from the bootstrap.

## Bootstrap

Run these inside the WSL Ubuntu shell.

### 1. Install chezmoi and apply the dotfiles

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply T-Py-T
```

This one command:

- Installs the `chezmoi` binary to `~/.local/bin`.
- Clones this repo to `~/.local/share/chezmoi`.
- Runs `run_once_before_setup` - installs Homebrew to `/home/linuxbrew` if missing (`brew doctor` output is informational and never aborts).
- Applies every `dot_*` file to `~` (zsh, bash, tmux, `~/.config/*`, and the global `~/mise.toml`).
- Runs `run_10_homebrew` - `brew bundle` against `brew/linux/dot_Brewfile.tmpl`.

### 2. Install the pinned runtimes

```sh
mise install
```

### 3. Start a fresh shell

Close and reopen the Ubuntu terminal (or `exec zsh` / `exec bash`) so mise activation, starship, and the modular shell config load.

## Verify

```sh
brew bundle check --file ~/.local/share/chezmoi/brew/linux/dot_Brewfile.tmpl   # "dependencies are satisfied"
mise current            # python/go/rust/node at pinned versions
chezmoi status          # empty = everything applied
```

## Keeping it current

```sh
chezmoi update          # pull latest from the repo and re-apply
brew upgrade
mise upgrade
```

## WSL-specific gotchas

| Concern | What to do |
|---|---|
| **Filesystem performance** | Keep all code under the Linux home (`~/`), never under `/mnt/c/`. Cross-OS filesystem access is roughly 100x slower. Clone repos into `~`. |
| **Windows PATH leaking in** | Windows PATH is appended to WSL by default, which can shadow Linux tools. If it causes problems, disable it in `/etc/wsl.conf`: add `[interop]` then `appendWindowsPath = false`, and `wsl --shutdown` from PowerShell to restart. |
| **systemd** | Recent WSL supports systemd. Enable it in `/etc/wsl.conf` (`[boot]` then `systemd=true`) only if you need user services; it is not required for this repo. |
| **GUI apps** | WSLg can run Linux GUI apps, but most are better installed on the Windows side. This repo installs no GUI apps on Linux anyway. |
| **VS Code** | Install VS Code on Windows and use the "WSL" remote extension; it runs the editor server inside the distro and picks up your `~/.config` there. |

## Troubleshooting

| Symptom | Fix |
|---|---|
| `wsl --install` does nothing / old Windows | Requires Windows 10 2004+ or Windows 11. Update Windows, or install WSL from the Microsoft Store. |
| `brew` not found after bootstrap | Start a new shell so the `00-homebrew` module runs `brew shellenv`. |
| `go`/`node` resolve to Homebrew, not the pinned version | Start a new shell - mise activates last so its shims win. |
| Everything is slow | You are probably working under `/mnt/c/`. Move the project into `~/`. |

See also: [Linux setup](linux.md) for the shared flow and [Runtime vs tool strategy](../README.md#runtime-vs-tool-strategy).
