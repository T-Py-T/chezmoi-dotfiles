# Deployment

How this repo gets applied to a fresh machine, and which platform variant fits which use case.

## Platform decision matrix

| Platform | Use this for | Avoid if |
|---|---|---|
| [Fedora Atomic (COSMIC)](fedora-atomic-cosmic.md) | Primary Linux laptop / desktop. Reproducible from scratch, immutable host, container-first workflow. | You need traditional `dnf install` on the host without containers. |
| [macOS](macos.md) | MacBook, Apple Silicon. GUI apps via Homebrew casks. | You want full immutability — macOS does not provide it. |
| [Devcontainer](devcontainer.md) | Per-project dev environment, CI runners, ephemeral cloud workspaces (DevPod). | You need GUI apps or system-level services. |
| [Linux traditional](linux-traditional.md) | WSL2, Ubuntu/Debian/Arch VMs, anywhere Atomic is not viable. | You have the choice — prefer Fedora Atomic for laptops. |

## The four-layer model

This repo is the middle two layers. The bottom and top are managed elsewhere:

```
Layer 4: AI tool configs    →  workspace-configs repo (separate)
Layer 3: Dotfiles + shell   →  chezmoi-dotfiles (this repo)
Layer 2: Runtimes + tools   →  mise.toml + Brewfile (this repo)
Layer 1: OS image           →  upstream Fedora Atomic / macOS / etc.
```

Each layer is independently rebuildable. We deliberately do not build a custom OS image (no BlueBuild, no bootc) — the chezmoi + Brewfile + Quadlet layers do all the customization, so the host stays stock and updates from upstream "just work."

## The universal bootstrap flow

Every platform follows the same three-step flow. What differs per platform is the prerequisites section (step 0).

```
0. Platform-specific prereqs    (see per-platform doc)
1. Install chezmoi + apply      sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <github-username>
2. chezmoi run_once_ scripts fire automatically:
   - run_once_before_setup.tmpl    installs Homebrew, runs brew doctor
   - run_10_homebrew                runs brew bundle on the right Brewfile
3. mise install                   reads mise.toml, installs pinned runtimes
```

After step 3 the machine is functionally complete. Anything else (signing into 1Password, configuring tailnet, cloning project repos) is per-machine drift that does not belong in dotfiles.

## How chezmoi picks the right Brewfile

The `scripts/run_10_homebrew` script branches on environment:

| Detection | Brewfile used |
|---|---|
| `DEVCONTAINER=1` env or `/.dockerenv` exists | `brew/devcontainer/dot_Brewfile.tmpl` |
| `uname -s` = `Linux` (covers Atomic, WSL, regular distros) | `brew/linux/dot_Brewfile.tmpl` |
| `uname -s` = `Darwin` | `brew/macos/dot_Brewfile.tmpl` |

There is intentionally no separate Brewfile for Fedora Atomic vs Ubuntu vs WSL. If a tool installs cleanly via Homebrew on Linux, it goes in the single Linux Brewfile. Atomic-specific things (Quadlet container files, `rpm-ostree` layered packages) live elsewhere — see the Fedora Atomic doc.

## What does NOT go in this repo

To keep the bootstrap fast and portable, these belong elsewhere:

- **Project source code** — separate repos.
- **AI tool configs** (Claude / Cursor / Gemini global rules) — `workspace-configs` repo, symlinked into `~`.
- **Per-machine secrets** — 1Password, kept out of git entirely. chezmoi has 1Password integration if needed later.
- **GUI app preferences** — only when they have a config file that lives under `~/.config/`. macOS plist tweaks via `defaults write` are out of scope; if needed, a separate setup script lives in `workspace-configs/macos-dev/`.
