#!/usr/bin/env bash
# .devcontainer/startup.sh
# Devcontainer setup path: mise -> chezmoi apply -> brew bundle -> nvim bootstrap.
# This is the single entry point for the devcontainer environment.
# Portable: copy .devcontainer/ to another project and this script handles everything.

set -euo pipefail

# DEVCONTAINER=1 is set in devcontainer.json containerEnv.
# Scripts that need to behave differently in containers check this var.
export DEVCONTAINER="${DEVCONTAINER:-1}"

if ! command -v mise >/dev/null 2>&1; then
  echo "mise is not installed in the container."
  exit 1
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi is not installed in the container."
  exit 1
fi

if [ -z "${CHEZMOI_SOURCE_DIR:-}" ]; then
  echo "CHEZMOI_SOURCE_DIR is not set."
  exit 1
fi

# Pre-configure PATH for Linux Homebrew so brew is available to chezmoi scripts
# after run_once_before_setup.tmpl installs it.
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# 1. Install language runtimes (python, go, rust, node)
mise trust --yes
mise install

# 2. Apply dotfiles - this runs:
#    - run_once_before_setup.tmpl  (installs Homebrew)
#    - run_10_homebrew             (brew bundle using devcontainer Brewfile)
#    - applies all dot_ files to $HOME
mise run chezmoi:init
mise run chezmoi:apply

# 3. Activate mise so runtimes are on PATH for the provider install steps
eval "$(mise activate bash)"

# 4. Install NeoVim language providers so :checkhealth passes
pip install --quiet pynvim 2>/dev/null || true
npm install -g neovim 2>/dev/null || true

# 5. Bootstrap NeoVim plugins (lazy.nvim)
timeout 120 nvim +LazySync +quit! 2>/dev/null || true
