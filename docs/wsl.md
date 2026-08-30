# WSL Setup (from scratch)

How to take a fresh Windows machine to a working Linux dev environment with this repo, running under WSL2 (Windows Subsystem for Linux).

WSL reports as Linux (`uname -s` = `Linux`, chezmoi `.os` = `linux`), so it uses the Linux bootstrap with a WSL-specific Brewfile selected by `scripts/run_10_homebrew`. What is different is getting WSL itself set up and a few Windows-integration gotchas.

Every command below was run in order on a clean Ubuntu 24.04 WSL2 distro. Expect the whole thing to take 30-45 minutes, almost all of it inside `brew bundle`.

## What you end up with

- A WSL2 Ubuntu distro with Homebrew (under `/home/linuxbrew`) and every CLI tool in `brew/linux/dot_Brewfile.tmpl`.
- Pinned language runtimes (python, go, rust, node) via mise.
- Shell (bash), prompt (starship), editor (neovim), tmux, and aliases configured in `~`.
- Linux-native Beads, OMP, Pi, and Hermes runtimes plus the shared agent-coordination skill. Nothing is installed into the Windows filesystem.

## Prerequisites

### 1. Install WSL2 and Ubuntu

From an elevated **PowerShell** (Run as Administrator) on Windows:

```powershell
wsl --install
```

This enables WSL2 and installs Ubuntu by default. Reboot if prompted, then launch **Ubuntu** from the Start menu and create your Linux username and password when asked.

Confirm you are on WSL2 (not WSL1):
```powershell
wsl --list --verbose
```
The `VERSION` column should read `2`. If it says `1`, convert it: `wsl --set-version Ubuntu 2`.

### 2. Install the Homebrew base packages

Inside the Ubuntu shell:

```sh
sudo apt update
sudo apt install -y build-essential curl file git procps
```

These five are the only `apt` packages you install by hand. Homebrew on Linux cannot bootstrap itself without them, and everything after this point is installed by Homebrew, mise, or the agent-runtime installer.

## Bootstrap

Run these inside the WSL Ubuntu shell. Do them in this order - each step depends on the one before it.

### 1. Install chezmoi

```sh
mkdir -p ~/.local/bin
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
```

`-b` is required. The installer's default install directory is `./bin`, relative to
your current directory, so without it you get `~/bin/chezmoi` (or a stray `bin/`
inside whatever directory you happened to be in). Ubuntu's stock `~/.profile`
already adds `~/.local/bin` to `PATH` when the directory exists, so this is a
one-time `export`; later shells pick it up automatically.

### 2. Clone and apply the dotfiles

```sh
chezmoi init --apply T-Py-T/chezmoi-dotfiles
```

Use the **full `owner/repo`**. The bare-username form (`chezmoi init --apply T-Py-T`)
expands to `github.com/T-Py-T/dotfiles`, which is a different, private, long-abandoned
repo - not this one. That is the single most common way this setup fails, and it is why
you would otherwise need `gh auth login` first. `T-Py-T/chezmoi-dotfiles` is public, so
no GitHub authentication is needed at all.

This one command:

- Clones this repo to `~/.local/share/chezmoi`.
- Runs `run_once_before_setup` - installs Homebrew to `/home/linuxbrew` if missing (`brew doctor` output is informational and never aborts; the `ykpers` deprecation warning is expected).
- Applies every `dot_*` file to `~` (bash, zsh, tmux, `~/.config/*`, and the global `~/mise.toml`).
- Runs `run_10_homebrew` - `brew bundle` against `brew/linux/dot_Brewfile-wsl.tmpl`, the WSL superset containing the shared Linux tools plus WSL terminal extras and the Agave Nerd Font. This is the slow part.
- Runs `run_after_20_agent_tools` inside WSL - installs the Linux release assets and keeps all agent state under the WSL home directory.

Two things to know about this step:

- `run_10_homebrew` finishes with `brew bundle cleanup --force`, which **uninstalls any
  formula that is not in the Brewfile.** If you brew-installed tools by hand before
  bootstrapping, they will be removed. Add them to `brew/linux/dot_Brewfile.tmpl` first
  if you want to keep them.
- Hermes may print `WARNING: Playwright browser installation failed` and
  `WARNING: uv.lock sync failed ... falling back to PyPI resolve`. Neither is fatal; the apply
  still exits 0. See troubleshooting below.

### 3. Start a fresh shell

```sh
exec bash
```

Do this **before** the next step. `mise` is installed by `brew bundle`, so it is not on
`PATH` in the shell that ran the bootstrap - running `mise install` there fails with
`mise: command not found`. A new shell loads `~/.config/bash/00-homebrew.bash`
(`brew shellenv`), then mise activation, then starship.

`exec zsh` will not work: zsh is deliberately not in the Linux Brewfile. `~/.zshrc` is
still deployed for machines that have zsh from elsewhere.

### 4. Install the pinned runtimes

```sh
mise install
```

Installs python, go, rust, and node at the versions pinned in `~/mise.toml`. Takes about
a minute. Then `exec bash` once more so the new shims resolve.

## Verify

```sh
mise current            # python/go/rust/node at the pinned versions
brew bundle check --file ~/.local/share/chezmoi/brew/linux/dot_Brewfile.tmpl
chezmoi status
agent-stack-doctor
```

Expected output:

```
$ mise current
python 3.14.3
go 1.25.7
rust 1.93.0
node 22.12.0

$ brew bundle check --file ~/.local/share/chezmoi/brew/linux/dot_Brewfile.tmpl
The Brewfile's dependencies are satisfied.

$ chezmoi status
 R scripts/10_homebrew
 R scripts/20_agent_tools

$ agent-stack-doctor
...
0 failure(s), 1 warning(s)
```

`chezmoi status` is **not** empty on a healthy machine. `run_10_homebrew` and
`run_after_20_agent_tools` are run-every-apply scripts, so chezmoi always lists them as
`R` (run). Only `M`/`A`/`D` lines on `dot_*` targets mean something is unapplied.

`agent-stack-doctor` reporting `warn codex is not installed` is expected - Codex is not
part of this repo's Brewfile. Only `failure(s)` matter.

## Keeping it current

```sh
chezmoi update          # pull latest from the repo and re-apply
brew upgrade
mise upgrade
agent-stack-doctor
```

## WSL-specific gotchas

| Concern | What to do |
|---|---|
| **Filesystem performance** | Keep all code under the Linux home (`~/`), never under `/mnt/c/`. Cross-OS filesystem access is roughly 100x slower. Clone repos into `~`. |
| **Windows PATH leaking in** | Windows PATH is appended to WSL by default, which can shadow Linux tools. If it causes problems, disable it in `/etc/wsl.conf`: add `[interop]` then `appendWindowsPath = false`, and `wsl --shutdown` from PowerShell to restart. |
| **systemd** | Recent WSL supports systemd. Enable it in `/etc/wsl.conf` (`[boot]` then `systemd=true`) only if you need user services; it is not required for this repo. |
| **GUI apps** | WSLg can run Linux GUI apps, but most are better installed on the Windows side. This repo installs no GUI apps on Linux anyway. |
| **VS Code** | Install VS Code on Windows and use the "WSL" remote extension; it runs the editor server inside the distro and picks up your `~/.config` there. |
| **Nerd Font glyphs** | `omp` and `yazi` render in Windows Terminal, so install the Linux cask and the font on Windows, then set the Windows Terminal profile font. See [nerd-fonts-wsl.md](nerd-fonts-wsl.md). |
| **Brewfile** | WSL uses `brew/linux/dot_Brewfile-wsl.tmpl`, a superset of the base Linux Brewfile selected automatically by `scripts/run_10_homebrew`. |

## Troubleshooting

| Symptom | Fix |
|---|---|
| `wsl --install` does nothing / old Windows | Requires Windows 10 2004+ or Windows 11. Update Windows, or install WSL from the Microsoft Store. |
| Clone asks for GitHub credentials, or `~/.local/share/chezmoi` ends up empty | You used the bare-username shorthand and hit the wrong (private) repo. Run `rm -rf ~/.local/share/chezmoi` and re-init with the full `T-Py-T/chezmoi-dotfiles`. |
| `chezmoi: command not found` right after install | You omitted `-b ~/.local/bin`; the binary is in `./bin` under whatever directory you ran the installer from. Re-run step 1. |
| `mise: command not found` | You skipped the fresh shell. Run `exec bash`, then `mise install`. |
| `brew` not found after bootstrap | Start a new shell so the `00-homebrew` module runs `brew shellenv`. |
| Homebrew formulae you installed by hand disappeared | `brew bundle cleanup --force` removed them. Add them to `brew/linux/dot_Brewfile.tmpl`. |
| `WARNING: Playwright browser installation failed` during the Hermes step | Non-fatal; only Hermes browser tools are affected. Fix later with `cd ~/.hermes/hermes-agent && npx playwright install chromium`. |
| `go`/`node` resolve to Homebrew, not the pinned version | Start a new shell - mise activates last so its shims win. |
| Everything is slow | You are probably working under `/mnt/c/`. Move the project into `~/`. |

See also: [Linux setup](linux.md) for the shared flow and [Runtime vs tool strategy](../README.md#runtime-vs-tool-strategy).
