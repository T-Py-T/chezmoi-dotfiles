#!/usr/bin/env bash
# scripts/devpod-up.sh
# Performs a full clean rebuild of the DevPod workspace with no residual data.
# This ensures no contamination from previous attempts.
# Runs mise (language runtimes) + Homebrew (CLI tools from brew/devcontainer/Brewfile)
# + chezmoi apply (dotfiles) + nvim headless boot (installs vim.pack plugins).

set -euo pipefail

workspace_id="${1:-dev}"

echo "Performing full clean rebuild of DevPod '${workspace_id}'..."
echo "This will:"
echo "  - Delete any existing workspace"
echo "  - Rebuild container from scratch"
echo "  - Clear all cached data"
echo ""

# Full clean rebuild with no residual data
devpod delete "${workspace_id}" --force 2>/dev/null || true

# Build fresh with reset flag
devpod up . --reset --id "${workspace_id}"

echo ""
echo "DevPod '${workspace_id}' is ready!"
echo "Connect with: devpod ssh ${workspace_id}"
