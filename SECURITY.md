# Security policy

## Supported code

The current `main` branch is the only supported version. This repository is a
personal chezmoi dotfiles tree for bootstrapping shells, editors, and local
developer tools; it does not operate a hosted service.

## Report a vulnerability

Do not open a public issue for an unpatched vulnerability.

Email the repository owner at [tnt850910@aol.com](mailto:tnt850910@aol.com). When
the repository Security tab offers it, you may also use GitHub's private
vulnerability reporting.

Include the affected commit, the vulnerable path, the impact, and the smallest
reproduction that does not expose sensitive data. You can expect an
acknowledgment within seven days. A fix schedule depends on the severity and
the affected component.

## Keep reports and evidence safe

- Do not send or commit tokens, API keys, SSH private keys, session data, agent
  credentials, or personal data.
- Do not attach unredacted `chezmoi` state, home-directory snapshots, or
  host-specific evidence packets that reveal live credentials or addresses.
- Use synthetic credentials and local fixtures when reproducing configuration or
  bootstrap defects.
- Treat captured third-party output under its original license and terms.

## Repository boundary

Runtime secrets and machine-specific state belong outside the repository. Never
commit a secret value, decrypted configuration, private backup, or unredacted
export of local customizations.

`dot_*`, `dot_config/`, `brew/`, `mise.toml`, and the scripts in `scripts/`
define how a workstation is bootstrapped and updated. They do not certify
third-party applications, language runtimes, or generated artifacts as secure.

Pre-commit checks, Neovim health validation, and `chezmoi update --dry-run` help
verify the public configuration in this repository. Local checks do not certify
a workstation, host operating system, or rendered home-directory state as
secure.
