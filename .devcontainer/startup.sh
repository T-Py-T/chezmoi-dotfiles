#!/usr/bin/env bash
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

mise install
mise run chezmoi:init
mise run chezmoi:apply
