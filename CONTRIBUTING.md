# Contributing

Focused fixes and documentation improvements are welcome. Large unsolicited
refactors are unlikely to merge in a personal dotfiles tree.

## Pull requests

1. Read [README.md](README.md), especially
   [Validate a change](README.md#validate-a-change).
2. Run `pre-commit run --all-files --show-diff-on-failure` before pushing.
3. For Neovim changes, also run `bash scripts/check-nvim-health.sh`.
4. Open a pull request against `main`. CI runs
   [Validate](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/validate.yml)
   and
   [Neovim Health](https://github.com/T-Py-T/chezmoi-dotfiles/actions/workflows/nvim-health.yml)
   on pull requests only.

## Security

Report vulnerabilities per [SECURITY.md](SECURITY.md). Do not open public
issues for unpatched security problems.

## License

Contributions to repository-owned configuration and documentation are accepted
under the same [MIT License](LICENSE) as the rest of the repository.
