# Hireability snapshot

Quick orientation for recruiters, hiring managers, and engineers reviewing this
repository as a work sample. Full setup and layout live in [README.md](../README.md).

## What

Cross-platform developer environment managed with
[chezmoi](https://www.chezmoi.io/): shells, Neovim, Homebrew bundles,
`mise`-pinned language runtimes, bootstrap scripts, and checksum-pinned portable
agent tooling. Supported targets include macOS, Linux, WSL, Fedora Atomic, and
development containers.

## Why

- One Git tree bootstraps a repeatable workstation without replacing the host OS.
- Machine-specific and secret state stay out of Git; `chezmoi` renders `dot_*`
  into `$HOME`.
- Tool ownership is explicit (Homebrew vs `mise` vs agent installers) and
  documented in [Runtime and tool ownership](runtime-tooling.md).

## How to evaluate

1. Read [README.md](../README.md) — managed layers, [repository layout](../README.md#repository-layout), and [quick start](../README.md#quick-start).
2. Skim recent PR workflow runs: [Validate](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/validate.yml) and [Neovim Health](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/nvim-health.yml) (gates run on pull requests only).
3. Review [SECURITY.md](../SECURITY.md) for supported versions and private reporting.
4. See [CONTRIBUTING.md](../CONTRIBUTING.md) for pull-request checks and scope.

## Topics

`chezmoi` · `dotfiles` · Zsh · Bash · Neovim · Homebrew · `mise` · tmux ·
Starship · pre-commit · GitHub Actions · cross-platform bootstrap · portable
agent coordination

## License

Repository-owned configuration and documentation:
[MIT License](../LICENSE).

## Tip-cite

Default-branch tip prefix: `c14963b8` (`main`). This pull request is pending
Steward resolve against that tip. Tip citation only — not READY, not a score or
bake-off claim, and not AUTH unpark.
