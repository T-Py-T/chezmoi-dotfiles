# dotfiles

My personal dotfiles, managed by [chezmoi](https://www.chezmoi.io/).

Targets macOS, Linux (incl. WSL and Fedora Atomic), and devcontainers from a single repo. The right Brewfile is picked automatically based on environment.

## Overview

One repo bootstraps a new machine to a working dev environment. It manages three layers:

- **Dotfiles** - zsh/bash, starship prompt, neovim, tmux, aliases, and `~/.config/*`, materialized into `~` by chezmoi.
- **Tools** - all CLI tools (and, on macOS, GUI casks + VS Code extensions) via Homebrew, from a per-OS Brewfile.
- **Runtimes** - python, go, rust, node pinned in `mise.toml` and identical on every OS.

The OS image itself stays stock (no custom image), and AI tool configs live in a separate `workspace-configs` repo. See [Runtime vs tool strategy](#runtime-vs-tool-strategy) for how mise and Homebrew divide responsibilities.

## Getting started

Full from-scratch walkthroughs, one per platform:

- **[macOS](docs/macos.md)** - Apple Silicon MacBook
- **[Linux](docs/linux.md)** - Ubuntu/Debian, Fedora, Arch, cloud VMs, servers
- **[WSL](docs/wsl.md)** - Windows Subsystem for Linux

Advanced environments: [Fedora Atomic](docs/fedora-atomic.md) (immutable desktop), [Devcontainer](docs/devcontainer.md) (per-project containers).

The short version, once your platform's prerequisites (from the guide above) are in place:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply T-Py-T   # chezmoi + Homebrew + dotfiles + brew bundle
mise install                                                   # pinned python/go/rust/node
```

Then open a new shell. That's it - see your platform guide for verification and troubleshooting.

Update an existing machine:

```sh
chezmoi update && brew upgrade && mise upgrade
```

## Repo layout

| Path | What it is |
|---|---|
| `dot_*` / `dot_config/` | Files that chezmoi materializes into `~` |
| `brew/{macos,linux,devcontainer}/` | Per-environment Brewfiles |
| `mise.toml` | Pinned language runtimes (python, go, rust, node) |
| `scripts/` | chezmoi `run_once_*` and `run_*` scripts |
| `docs/` | Per-OS setup guides, plus findings and reference |
| `.chezmoiignore` | Keeps repo infra (README, `docs`, `brew/`, helper scripts) out of `~` |

## Runtime vs tool strategy

Read this before changing anything about package management. The goal is simple:
**install the same tools no matter the operating system.** These decisions are
settled; do not relitigate them without a concrete reason.

The split:

- **mise owns language runtimes** (python, go, rust, node). Versions are pinned in
  `mise.toml`, so every OS gets identical runtimes. `mise.toml` deploys to `~`
  (global) so runtimes resolve in every directory.
- **Homebrew owns everything else** (CLI tools and GUI casks), via the per-OS
  Brewfile under `brew/<os>/`. Homebrew may pull `go`/`node` in as transitive
  dependencies; that is fine because of the PATH rule below.

Non-negotiable mechanics:

- **mise activates LAST** in `dot_zshrc` / `dot_bashrc`, after the Homebrew
  shellenv module. This makes mise's runtime shims win over any brew `go`/`node`
  on PATH, in interactive shells and non-interactive scripts alike. Do NOT move
  `mise activate` earlier.
- **`go install` output goes to `~/go/bin`, never mise's GOROOT.** mise sets
  `GOBIN` to the go version's `bin/` by default; go-installed tools landing there
  can corrupt the pinned go binary. The shell rc overrides `GOBIN="$HOME/go/bin"`
  after activation and puts `~/go/bin` on PATH (this is where `gopls` lives).

Settled decisions (an agent "fixing" any of these is creating a regression):

- **mise itself is installed via Homebrew** (it is in every Brewfile). Brew manages
  mise's updates. Do not remove it or replace it with a curl bootstrap.
- **No `pyenv`, no brew `python@X`.** mise owns python. Those were removed
  deliberately.
- **LSP servers (`pyright`) and `gopls` come from Homebrew / `go install`,** not
  mise. mise is runtimes only.
- **Keep `.chezmoiignore`.** Without it, `chezmoi apply` dumps `README.md`,
  `docs/`, `brew/`, and helper scripts into `~`.
- **Third-party taps carry `trusted: true`** in the Brewfiles. Homebrew refuses
  to load casks/formulae from untrusted taps, which aborts `brew bundle`.
- **`adobe-acrobat-reader` is intentionally absent.** Adobe's installer rejects
  Homebrew-managed upgrades and breaks `brew bundle`; install Reader manually.

## Inspirations

- [Mischa van den Burg](https://mischavandenburg.com/) — Fedora Atomic + chezmoi + Podman Quadlet workflow
- [mloberg](https://github.com/mloberg/dotfiles)
- [Dreams of Autonomy](https://www.youtube.com/watch?v=9U8LCjuQzdc)
- [Josean Martinez](https://www.youtube.com/@joseanmartinez)
