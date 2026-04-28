# macOS Deployment

Current laptop setup. MacBook (Apple Silicon).

## What this covers

The full provisioning flow from a freshly-imaged Mac to a working dev environment using this repo plus the `workspace-configs` repo for AI tool configs.

## Why macOS in this repo

macOS is the daily driver and has been since before this repo existed. Atomic Linux is the goal for the next laptop refresh, but until that happens, macOS is treated as a first-class platform here.

## What is macOS-specific

| Concern | macOS-specific bit |
|---|---|
| Brewfile | `brew/macos/dot_Brewfile.tmpl` includes `cask` entries for GUI apps and `vscode` entries for extensions. |
| Homebrew install path | `/opt/homebrew/` on Apple Silicon (vs `/home/linuxbrew/` on Linux). |
| GUI apps | All via `brew install --cask`. No App Store automation. |
| Fonts | Nerd Fonts come via `brew install --cask font-meslo-lg-nerd-font`. |
| GPG / SSH agent | `pinentry-mac` for GPG, `ssh-add --apple-use-keychain` for SSH passphrase storage. |
| System defaults | NOT in this repo. Lives in `workspace-configs/macos-dev/` (separate concerns). |

Everything else (zsh config, neovim config, mise, starship, shared aliases) is shared with Linux.

## Initial install (zero to working laptop)

### 0. Out-of-box macOS setup
1. Sign into Apple ID, iCloud, etc.
2. Set computer name in System Settings → General → About.
3. Enable FileVault.
4. Install Xcode Command Line Tools when prompted (or `xcode-select --install`).

### 1. Bootstrap chezmoi
```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <github-username>
```

This runs:
- `run_once_before_setup.tmpl` — installs Homebrew to `/opt/homebrew/`, runs `brew doctor`.
- Applies all dotfiles to `~`.
- `run_10_homebrew` — `brew bundle` against `brew/macos/dot_Brewfile.tmpl`. Pulls down all CLI tools, casks, and VS Code extensions.

This step takes the longest because of the cask downloads. Let it run.

### 2. Install pinned runtimes
```
mise install
```

### 3. Symlink AI tool configs
```
cd ~/Library/CloudStorage/Dropbox/_GitHub
git clone <workspace-configs-url>
cd workspace-configs
./setup-ai-tools.sh
```

### 4. macOS-specific tweaks (separate)
Anything that requires `defaults write` or System Settings changes lives in `workspace-configs/macos-dev/`. Run those scripts separately.

### 5. Sign into stateful things
1Password, iCloud Keychain, Slack, Notion, etc.

## What is NOT in the macOS Brewfile

Intentionally excluded:

| Thing | Why it is not in the Brewfile |
|---|---|
| `mise` itself | Bootstrapped via curl in `run_once_before_setup.tmpl`. mise can self-install language runtimes; let it manage itself. |
| Python / Node / Go / Rust | Managed by mise, not Homebrew. Pinned versions in `mise.toml`. |
| App Store apps (Xcode, Pages, etc.) | No reliable automation path. Install manually. |
| 1Password browser extension | Installs via the 1Password app itself. |

## Common gotchas

| Issue | Cause | Fix |
|---|---|---|
| `brew bundle` fails on first `cask` install | Gatekeeper has not approved Homebrew's helper | Run `brew install --cask <whatever>` once manually, approve in System Settings → Privacy & Security, then re-run `chezmoi apply`. |
| VSCode extensions don't install | VS Code not yet installed when `vscode` entries run | The Brewfile installs `cask "visual-studio-code"` before `vscode` entries — this should not happen. If it does, run `brew bundle` again. |
| Fonts not showing in iTerm2 / WezTerm | App was open during `brew bundle` | Restart the terminal app. |
| `gh auth login` opens browser to wrong account | Cookie collision with another GitHub account | Use `gh auth login --web --hostname github.com` and carefully pick the account. |
| `npm install -g` fails after `mise install node` | mise's node shim does not include npm by default in some versions | Run `mise use --global node@<version>` to materialize the shims. |

## Updating an existing machine

```
chezmoi update    # pulls latest from this repo and re-applies
brew update && brew upgrade
mise upgrade
```

A weekly habit.
