# .devcontainer/startup.sh
# Bootstraps mise tools and runs local chezmoi tasks.
# Does not apply dotfiles unless the tasks are invoked.

set -euo pipefail

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

export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

mise trust --yes
mise install
mise run chezmoi:init
mise run chezmoi:apply

# Bootstrap NeoVim plugins (lazy.nvim)
eval "$(mise activate bash)"
timeout 120 nvim +LazySync +quit! 2>/dev/null || true
