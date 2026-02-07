#!/usr/bin/env bash
# scripts/devpod-up.sh
# Starts a DevPod workspace with brew skipped.
# Does not manage existing workspaces beyond reset.
set -euo pipefail

workspace_id="${1:-dev}"

devpod up . --reset --id "${workspace_id}" --workspace-env SKIP_BREW=1
