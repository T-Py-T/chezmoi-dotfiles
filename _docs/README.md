# _docs

Internal documentation for this dotfiles repo. Findings, decisions, and deployment strategies that don't belong in the top-level `README.md`.

## Layout

```
_docs/
├── deployment/   How to bootstrap this repo on different OSes / desktops
└── findings/     Research notes, gotchas, and troubleshooting writeups
```

## Why a separate folder?

The root `README.md` should stay short — install chezmoi, init from this repo, done. Anything that requires more than two paragraphs of explanation belongs here so the README does not bloat.

The leading underscore (`_docs`) sorts the folder near the top of file listings alongside `.github/` and `.mise/`, and makes it visually obvious it is meta-documentation, not code.

## Quick links

- [Deployment overview](deployment/README.md) — which platform for what purpose, plus the universal bootstrap flow
- [Fedora Atomic (COSMIC)](deployment/fedora-atomic-cosmic.md) — preferred Linux desktop strategy
- [macOS](deployment/macos.md) — current laptop setup
- [Devcontainer](deployment/devcontainer.md) — minimal containerized environment
- [Linux traditional](deployment/linux-traditional.md) — Ubuntu/Arch/WSL fallback notes

## Conventions

- One markdown file per platform under `deployment/`. Keep each file self-contained — duplication beats indirection.
- Findings under `findings/` are dated where useful (e.g. `2026-04-neovim-migration.md`) so historical context is preserved.
- Decisions that change behavior across platforms get a short ADR-style note under `findings/` linking to the commit that made the change.
