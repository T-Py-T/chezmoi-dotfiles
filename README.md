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
