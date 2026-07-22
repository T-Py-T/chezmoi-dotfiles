# macOS Setup (from scratch)

How to take a brand-new Apple Silicon Mac to a working dev environment with this repo.

## What you end up with

- Homebrew with every CLI tool, GUI cask, and VS Code extension in `brew/macos/dot_Brewfile.tmpl`.
- Pinned language runtimes (python, go, rust, node) via mise.
- Shell (zsh), prompt (starship), editor (neovim), tmux, and aliases configured in `~`.

The whole thing is three commands after the prerequisites. Budget ~20-30 minutes, mostly download time.

## Prerequisites

1. **macOS on Apple Silicon.** Homebrew installs to `/opt/homebrew`.
2. **Finish the out-of-box setup** (Apple ID, computer name, FileVault) if you want it.
3. **Xcode Command Line Tools** - Homebrew and git need them:
   ```sh
   xcode-select --install
   ```
   Accept the GUI prompt and wait for it to finish before continuing.

Nothing else is required. You do not install Homebrew, chezmoi, or mise by hand - the bootstrap does it.

## Bootstrap

### 1. Install chezmoi and apply the dotfiles

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply T-Py-T
```

This one command:

- Installs the `chezmoi` binary to `~/.local/bin`.
- Clones this repo to `~/.local/share/chezmoi`.
- Runs `run_once_before_setup` - installs Homebrew to `/opt/homebrew` if missing (`brew doctor` output is informational and never aborts).
- Applies every `dot_*` file to `~` (zsh, bash, tmux, `~/.config/*`, and the global `~/mise.toml`).
- Runs `run_10_homebrew` - `brew bundle` against `brew/macos/dot_Brewfile.tmpl`, installing all CLI tools, casks, and VS Code extensions.

The Brewfile step is the long one (cask downloads). Let it run.

### 2. Install the pinned runtimes

```sh
mise install
```

Reads `~/mise.toml` and installs python, go, rust, and node at the pinned versions.

### 3. Start a fresh shell

Open a new terminal (or `exec zsh`) so mise activation, starship, and the modular zsh config load.

## Verify

```sh
brew bundle check --file ~/.local/share/chezmoi/brew/macos/dot_Brewfile.tmpl   # "dependencies are satisfied"
mise current            # python/go/rust/node at pinned versions
which go node python    # all resolve under ~/.local/share/mise/installs/...
chezmoi status          # empty = everything applied
```

## Keeping it current

```sh
chezmoi update          # pull latest from the repo and re-apply (re-runs brew bundle)
brew upgrade            # upgrade installed formulae/casks
mise upgrade            # bump runtimes within the pins
```

A weekly habit.

## What is NOT automated

Deliberately out of scope - do these by hand:

- **App Store apps** (Xcode, Pages, etc.) - no reliable automation path.
- **macOS system defaults** (`defaults write`, System Settings) - not in this repo.
- **AI tool configs** - live in the separate `workspace-configs` repo.
- **Signing into stateful apps** - 1Password, iCloud, Slack, etc.
- **`adobe-acrobat-reader`** - Adobe's installer rejects Homebrew-managed upgrades, so it is intentionally not in the Brewfile. Install Reader from Adobe if you want it.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `brew bundle` fails on the first cask | Gatekeeper has not approved Homebrew's helper. Run `brew install --cask <name>` once, approve in System Settings -> Privacy & Security, re-run `chezmoi apply`. |
| A third-party tap is "not trusted" | The Brewfile pins `trusted: true` on third-party taps; make sure you are on the latest repo (`chezmoi update`). |
| `go`/`node` resolve to Homebrew, not the pinned version | Start a new shell. mise activates last in `.zshrc` so its shims win; a stale shell may predate that. |
| Fonts not showing in the terminal | The terminal app was open during `brew bundle`. Restart it. |
| VS Code extensions did not install | VS Code was not present when the `vscode` entries ran. Re-run `brew bundle`. |

See also: [Runtime vs tool strategy](../README.md#runtime-vs-tool-strategy) for how mise and Homebrew divide responsibilities.
