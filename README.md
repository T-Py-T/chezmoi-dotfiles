# dotfiles

My personal dotfiles, managed by [chezmoi](https://www.chezmoi.io/).

Targets macOS, Fedora Atomic (COSMIC), traditional Linux (incl. WSL), and devcontainers from a single repo. The right Brewfile is picked automatically based on environment.

## Setting up on a new machine

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

Per-platform prerequisites and the full bootstrap flow are documented in [`_docs/deployment/`](_docs/deployment/README.md).

## Updating dotfiles on a machine

```
chezmoi update
```

## Repo layout

| Path | What it is |
|---|---|
| `dot_*` / `dot_config/` | Files that chezmoi materializes into `~` |
| `brew/{macos,linux,devcontainer}/` | Per-environment Brewfiles |
| `mise.toml` | Pinned language runtimes (python, go, rust, node) |
| `scripts/` | chezmoi `run_once_*` and `run_*` scripts |
| `_docs/` | Deployment strategies, findings, decisions |
| `.chezmoiignore` | Keeps repo infra (README, `_docs`, `brew/`, helper scripts) out of `~` |

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
  `_docs/`, `brew/`, and helper scripts into `~`.
- **Third-party taps carry `trusted: true`** in the Brewfiles. Homebrew refuses
  to load casks/formulae from untrusted taps, which aborts `brew bundle`.
- **`adobe-acrobat-reader` is intentionally absent.** Adobe's installer rejects
  Homebrew-managed upgrades and breaks `brew bundle`; install Reader manually.

## Supported platforms

| Platform | Status | Doc |
|---|---|---|
| macOS (Apple Silicon) | Daily driver | [`_docs/deployment/macos.md`](_docs/deployment/macos.md) |
| Fedora Atomic (COSMIC) | Strategy documented, not yet daily-driven | [`_docs/deployment/fedora-atomic-cosmic.md`](_docs/deployment/fedora-atomic-cosmic.md) |
| Devcontainer / DevPod | Used across 6 project devcontainers | [`_docs/deployment/devcontainer.md`](_docs/deployment/devcontainer.md) |
| Linux traditional / WSL | Fallback when Atomic isn't an option | [`_docs/deployment/linux-traditional.md`](_docs/deployment/linux-traditional.md) |

## Inspirations

- [Mischa van den Burg](https://mischavandenburg.com/) — Fedora Atomic + chezmoi + Podman Quadlet workflow
- [mloberg](https://github.com/mloberg/dotfiles)
- [Dreams of Autonomy](https://www.youtube.com/watch?v=9U8LCjuQzdc)
- [Josean Martinez](https://www.youtube.com/@joseanmartinez)
