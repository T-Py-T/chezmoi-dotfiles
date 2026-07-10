# Linux (Traditional) Deployment

Catch-all for Linux that is **not** Fedora Atomic and **not** a devcontainer. Covers WSL2, Ubuntu/Debian VMs, regular (non-Atomic) Fedora, Arch, and similar.

## When to use this path

| Scenario | Why this and not Fedora Atomic |
|---|---|
| WSL2 on a Windows work machine | Atomic does not run under WSL. WSL2 ships with Ubuntu by default. |
| Cloud VM (EC2, Linode, DigitalOcean) | Distro is dictated by the AMI. Usually Ubuntu or Amazon Linux. |
| Existing Linux install you don't want to replace | Migrating an established machine to Atomic is non-trivial. Layer this repo on top of what is there. |
| Server you SSH into | No GUI, no desktop, just chezmoi + Brewfile + mise. |

If the choice is yours and the machine is a personal laptop, prefer [Fedora Atomic](fedora-atomic-cosmic.md). This doc is the fallback.

## What works out of the box

The bootstrap flow is identical to other platforms because `scripts/run_10_homebrew` only branches on `uname -s`, not the distro:

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <github-username>
mise install
```

This will:
1. Install Homebrew to `/home/linuxbrew/`.
2. Run `brew bundle` against `brew/linux/dot_Brewfile.tmpl`.
3. Install language runtimes via mise.

No distro-specific code branches in this repo today. If a distro needs special handling, add it to `scripts/run_once_before_setup.tmpl` with a `chezmoi.osRelease.id` template guard.

## Distro-specific prereqs

Before running the chezmoi bootstrap, install the bare minimum for Homebrew on Linux. The exact command differs per distro:

### Ubuntu / Debian / WSL2 Ubuntu
```
sudo apt update
sudo apt install -y build-essential curl file git procps
```

### Fedora (non-Atomic)
```
sudo dnf install -y @development-tools curl file git procps-ng
```

### Arch
```
sudo pacman -S --needed base-devel curl file git procps-ng
```

These are required by Homebrew itself. The chezmoi `run_once_before_setup.tmpl` will then handle installing brew.

## WSL2-specific notes

| Concern | Notes |
|---|---|
| Filesystem performance | Keep all code under `~/`, never under `/mnt/c/`. Cross-mount filesystem hits are 100x slower. |
| GUI apps | WSLg supports them. Most are still better installed on the Windows side. |
| systemd | Enable via `/etc/wsl.conf` if needed for Quadlet-style services (uncommon in WSL). |
| Path collision | Windows PATH leaks into WSL by default. Disable in `/etc/wsl.conf` if it causes issues. |
| Chezmoi `.os` template | Returns `linux` correctly under WSL. No special handling needed. |
| Nerd Font glyphs (omp, yazi) | Terminal renders with Windows-side fonts, not Linux fontconfig. Needs a two-part install — see [nerd-fonts-wsl.md](nerd-fonts-wsl.md). |
| Brewfile | WSL uses the superset `brew/linux/dot_Brewfile-wsl.tmpl` (base + terminal extras), auto-selected by `scripts/run_10_homebrew`. |

## Cloud VM-specific notes

For ephemeral cloud VMs that exist for hours-to-days, this repo is overkill. A simpler bash script that installs ripgrep + fzf + nvim is faster. Use chezmoi here only if:
- The VM is long-lived (your dev VM, your homelab box).
- Multiple VMs need identical setup.
- You expect to SSH in regularly and want your normal shell experience.

## What is NOT covered here

Things this doc deliberately does not address:

- **Display server / window manager setup** — out of scope. If you are running X11 or Wayland, you are presumably already past basic setup.
- **GPU drivers** — distro-specific, hardware-specific. Nothing here will help.
- **systemd unit files for system services** — for Atomic, see the Quadlet pattern in [fedora-atomic-cosmic.md](fedora-atomic-cosmic.md). For traditional Linux, write the unit, install it manually, document it in your project's repo.

## Migrating from traditional Linux to Atomic

If you are reading this on an Ubuntu laptop and want to move to Fedora Atomic, **don't try to in-place migrate.** Back up `~/`, fresh-install Atomic, run the bootstrap on the clean install. The whole point of Atomic is that the OS layer is reproducible from upstream — there is nothing of value to preserve from the old install except your home directory contents.
