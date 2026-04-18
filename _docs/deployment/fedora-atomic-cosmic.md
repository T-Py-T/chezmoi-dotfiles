# Fedora COSMIC Atomic Deployment

Strategy for using this repo on Fedora COSMIC Atomic as the primary Linux desktop. The same approach works for any Fedora Atomic variant (Silverblue, Kinoite, Sway Atomic, Bluefin, Aurora) — only the base image changes.

## Why this combination

**Fedora Atomic** gives an immutable, image-based host with `rpm-ostree`. Updates are atomic, rollbacks are one command, and the system state is reproducible because nothing on the host is hand-installed.

**COSMIC** is System76's Rust-based desktop, shipped officially as Fedora COSMIC Atomic 43 (released October 28, 2025). Modern, fast, fewer GNOME assumptions baked in.

**chezmoi + Brewfile + mise** handle everything customizable:
- Shell, prompt, editor, aliases — chezmoi manages files in `~`
- CLI tools (ripgrep, fzf, lazygit, kubectl) — Homebrew, isolated under `/home/linuxbrew/`
- Language runtimes (python, node, go, rust) — mise, pinned versions

**Podman Quadlet** handles system-level services (Tailscale, Docker registries, dev databases) — they run as rootless containers managed by systemd, with the `.container` files committed to this repo.

The result: **the host stays bone stock. All customization lives in two git repos. A new machine reaches a working state in roughly 15 minutes of mostly-waiting-for-downloads.**

## Why not a custom OS image (BlueBuild / bootc)?

Custom images are tempting and many people on r/Fedora swear by them. They are skipped here on purpose:

- The chezmoi + Brewfile + Quadlet layers already cover ~95% of what people put into custom images.
- A custom image adds a CI/CD pipeline to maintain (GitHub Actions, GHCR, signing keys, image rebases on every change).
- Upstream Fedora COSMIC Atomic updates daily anyway. A custom image means rebuilding to track upstream.
- The remaining ~5% (kernel modules, hardware drivers) is small enough to handle with a one-line `rpm-ostree install` and document here.

If the host ever needs more than 5–10 layered packages, revisit this decision.

## Variant selection: vanilla COSMIC Atomic vs Bluefin/Aurora

| Variant | Base | Pre-installed dev tooling | Pick if |
|---|---|---|---|
| **Fedora COSMIC Atomic** (vanilla) | Fedora upstream | Minimal — Firefox, basic GNOME utilities | You want the cleanest base and don't mind installing Docker / Distrobox / VS Code yourself via Brewfile or Flatpak. |
| **Bluefin-DX** (uBlue) | Silverblue + curated dev stack | Docker, Podman, Distrobox, VS Code, Homebrew, DevPod-ready | You want a turnkey dev experience and accept the opinions of the uBlue maintainers. GNOME only. |
| **Aurora-DX** (uBlue) | Kinoite + same dev stack | Same as Bluefin-DX | Same as Bluefin-DX but you want KDE Plasma. |

**Recommendation:** start with **vanilla Fedora COSMIC Atomic** if COSMIC is the desktop you want. Bluefin-DX is GNOME, Aurora-DX is KDE — neither ships COSMIC at the time of writing.

If you discover you are constantly layering the same packages that Bluefin-DX includes by default, rebase to Bluefin-DX with one command:
```
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bluefin-dx:latest
```

## What goes in which layer

This is the most important decision and easy to get wrong. Use these rules:

### Layer 1 — On the host (rpm-ostree)
**Only when there is no other option.** Adding packages here slows `rpm-ostree upgrade` because the local tree must be rebuilt every update.

Layer here if:
- It is a kernel module / driver (NVIDIA, Wi-Fi firmware, virtualbox-host).
- It needs a system-level systemd unit that cannot run rootless (rare).
- It is a desktop integration that Flatpak cannot provide (e.g. `1password` GUI when you want host-level CLI/SSH agent integration; the Flatpak does not expose the SSH agent).

Document every layered package in this repo (in this file, in the "Host packages" section below).

### Layer 2 — Flatpak
GUI applications. Browsers, communication apps, IDEs. These are isolated and update independently of the OS. Do not layer GUI apps via `rpm-ostree`.

### Layer 3 — Homebrew (CLI tools)
Anything in `brew/linux/dot_Brewfile.tmpl`. ripgrep, fzf, lazygit, kubectl, gh, starship, neovim, etc. Homebrew lives in `/home/linuxbrew/`, completely outside the immutable `/usr`, so it is safe on Atomic.

### Layer 4 — mise (language runtimes)
python, node, go, rust. Versions are pinned in `mise.toml`. Same as on macOS — no Atomic-specific changes.

### Layer 5 — Podman Quadlet (system services as containers)
Tailscale, dev databases, internal services. Rootless Podman containers managed by systemd. Files live under `~/.config/containers/systemd/*.container` and are committed to this repo (see "Quadlet pattern" below).

### Layer 6 — Distrobox (escape hatch)
For tools that absolutely require a traditional package manager (legacy CUDA stacks, weird scientific software, anything wanting `apt`). Create a Distrobox once, treat it as disposable, do not store state inside it.

### Layer 7 — Devcontainers / DevPod
Per-project dev environments. The host has Podman/Docker; everything else is per-project in `.devcontainer/`.

## Initial install (zero to working desktop)

### 0. Burn ISO and install
1. Download Fedora COSMIC Atomic 43 OSTree ISO from <https://fedoraproject.org/atomic-desktops/cosmic/download>.
2. Verify the checksum (the page links to instructions).
3. Write to USB with Fedora Media Writer or `dd`.
4. Boot, install, set up your user account. Reboot.
5. Sign into Firefox / browser of choice, install GNOME Extensions or COSMIC equivalents you want.

### 1. Bootstrap CLI prereqs
The base install does not include `git` on the host (it is expected to come via Distrobox or Flatpak). Layer the bare minimum needed to clone this repo:
```
rpm-ostree install git gh
systemctl reboot
```
After reboot, sign into GitHub:
```
gh auth login
```

### 2. Apply chezmoi
```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <github-username>
```

This single command:
- Installs the chezmoi binary into `~/.local/bin`
- Clones this repo to `~/.local/share/chezmoi`
- Runs `run_once_before_setup.tmpl` → installs Homebrew if missing
- Applies all dotfiles to `~`
- Runs `run_10_homebrew` → executes `brew bundle` against `brew/linux/dot_Brewfile.tmpl`

### 3. Install pinned runtimes
```
mise install
```
Reads `~/.config/mise/config.toml` (managed by chezmoi from `mise.toml` in this repo). Installs python, node, go, rust at the pinned versions.

### 4. Symlink AI tool configs (separate repo)
```
cd ~/_GitHub
git clone <workspace-configs-url>
cd workspace-configs
./setup-ai-tools.sh
```

### 5. Sign into anything stateful
1Password, Tailscale, GitHub, cloud CLIs. None of this is in dotfiles.

Total elapsed: ~15 minutes, mostly download time.

## Quadlet pattern for system services

Pattern adapted from Mischa van den Burg's writeup ([Tailscale on Fedora Atomic with Podman Quadlet](https://mischavandenburg.com/zet/tailscale-on-fedora-atomic-with-podman-quadlet/)). Run system services as rootless Podman containers managed by systemd, with the unit files committed to this repo.

### Where the files live in chezmoi

```
chezmoi-dotfiles/
└── dot_config/
    └── containers/
        └── systemd/
            └── tailscale.container.tmpl
```

After `chezmoi apply`, this materializes as `~/.config/containers/systemd/tailscale.container`.

### Activating after apply

Quadlet files are not picked up automatically. After dotfiles are applied:
```
systemctl --user daemon-reload
systemctl --user enable --now tailscale
```

For services that must run at boot before login, use the system Quadlet path (`/etc/containers/systemd/`) instead. That requires root and is layered into the host, not chezmoi-managed — document such services here.

### Why this beats layering Tailscale via rpm-ostree

- The container is pinned to a specific image version (reproducible).
- The unit file is in git (auditable, portable to another machine).
- Updates are `podman pull` + restart, not a host reboot.
- Removal is one command, no host residue.

This pattern is currently **not yet implemented** in this repo — it is documented here so that adding the first Quadlet file (likely Tailscale) follows a known structure.

## Devcontainer / DevPod compatibility

Bluefin-DX includes Docker and DevPod dependencies by default. On vanilla Fedora COSMIC Atomic, Docker is not pre-installed; use Podman (which is). Two options:

1. **Use Podman directly via DevPod's podman provider.** Works for most devcontainer setups.
2. **Layer `docker-ce` via rpm-ostree** if a project explicitly requires Docker. Document here when added.

Either way, the existing `brew/devcontainer/dot_Brewfile.tmpl` is what the devcontainer uses internally — no changes needed for Fedora Atomic on the host.

## Secrets bootstrap

1Password CLI (`op`) is the chosen secret manager. On Atomic, the cleanest install is the official 1Password RPM repo + `rpm-ostree install 1password 1password-cli`. The Flatpak version of 1Password does not expose the SSH agent or browser integration the way the native package does.

Document the `op` setup steps here once executed (signing in on a fresh machine, importing SSH keys, etc.) so the next bootstrap is one command.

## Common gotchas

| Issue | Cause | Fix |
|---|---|---|
| `brew doctor` complains about `/usr/local` not being writable | Atomic has read-only `/usr` | Ignore — `brew doctor` is non-fatal in `run_once_before_setup.tmpl`. The actual install path is `/home/linuxbrew/`, which is writable. |
| `tree-sitter-cli` install fails inside nvim | `npm` not on PATH yet | The `dot_zshrc` auto-installs `tree-sitter-cli` via `npm` if both are present. mise must be active. New shell after `mise install`. |
| Quadlet container fails to start | `TS_USERSPACE=true` missing for rootless Tailscale | Rootless Podman cannot access `/dev/net/tun`. See Mischa's writeup linked above. |
| First-boot SSH agent does not see 1Password keys | 1Password native app needs to be running and unlocked | Open 1Password GUI first, then start your terminal. Auto-start 1Password in COSMIC autostart. |
| Layered packages making `rpm-ostree upgrade` very slow | Too many layered packages | Audit the host packages list below. If more than ~5, consider rebasing to Bluefin-DX or building a custom image. |

## Host packages (audit list)

Layered packages on the host. Keep this list as short as possible. If it grows past ~5, reconsider variant choice.

| Package | Why it must be on the host | Date added |
|---|---|---|
| `git` | Needed to bootstrap chezmoi from a fresh install | (record on first install) |
| `gh` | GitHub auth before any other git operations | (record on first install) |
| `1password` | SSH agent and browser integration require native app | (record when added) |
| `1password-cli` | Required by 1Password native app | (record when added) |

When layering a new package, add a row here in the same commit.

## References

- [Fedora COSMIC Atomic download](https://fedoraproject.org/atomic-desktops/cosmic/download)
- [rpm-ostree documentation](https://coreos.github.io/rpm-ostree/)
- [Podman Quadlet documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
- [Mischa van den Burg — Tailscale on Fedora Atomic with Podman Quadlet](https://mischavandenburg.com/zet/tailscale-on-fedora-atomic-with-podman-quadlet/)
- [Universal Blue (Bluefin / Aurora)](https://universal-blue.org/)
- [Distrobox documentation](https://distrobox.it/)
