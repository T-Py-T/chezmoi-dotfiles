# Runtime and tool ownership

The workstation stays predictable by giving each package category one update
authority.

## Ownership model

| Category | Owner | Source |
| --- | --- | --- |
| Python, Go, Rust, Node | `mise` | Versions in [`mise.toml`](../mise.toml) |
| CLI tools, GUI apps, extensions | Homebrew | Brewfiles under [`brew/`](../brew) |
| Beads, OMP, Pi, Hermes | Agent runtime installer | Pinned releases and checksums in [`scripts/run_after_20_agent_tools.tmpl`](../scripts/run_after_20_agent_tools.tmpl) |

Homebrew can install a language runtime as a transitive dependency. That copy is
not selected for development: `mise` activates after Homebrew in the shell
startup files, so its shims take precedence.

## PATH rules

- Keep `mise activate` after the Homebrew shell environment in Zsh and Bash.
- Set `GOBIN="$HOME/go/bin"` after `mise` activates. This keeps `go install`
  output outside the managed Go installation.
- Keep `~/go/bin` on `PATH` for Go-installed tools such as `gopls`.
- Keep `.chezmoiignore`; it prevents repository documentation and support files
  from being copied into the home directory.

## Package boundaries

- Homebrew installs and updates `mise` itself.
- Do not add `pyenv` or versioned Homebrew Python formulae; `mise` owns Python.
- Homebrew or `go install` owns language servers such as `pyright` and `gopls`.
- Do not add Beads, OMP, Pi, or Hermes to a Brewfile. The pinned installer is
  their update authority.
- Third-party taps remain explicitly trusted where Homebrew requires that flag
  for `brew bundle`.
- Adobe Acrobat Reader is installed manually because its installer does not
  cooperate with Homebrew-managed upgrades.

## Agent runtime safety

The agent installer writes versioned payloads beneath
`~/.local/share/agent-tools` and manages symlinks in `~/.local/bin`. It refuses
to replace regular files and stops if the retained Hermes checkout is dirty.

Never store agent credentials, session data, databases, caches, pairing state,
or memory content in this dotfiles repository. See
[Portable agent coordination stack](agent-stack.md) for installation and
operating details.
