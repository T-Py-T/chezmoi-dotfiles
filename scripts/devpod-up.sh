#!/usr/bin/env bash
# scripts/devpod-up.sh
# Starts a DevPod workspace with customizable workspace ID.
# Homebrew is installed but Brewfiles are empty (tools via mise).

set -euo pipefail

workspace_id="${1:-dev}"

devpod up . --reset --id "${workspace_id}"
