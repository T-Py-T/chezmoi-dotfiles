#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

bash tests/test_pinned_version_matching.sh
bash tests/test_pi_incomplete_install_recovery.sh

echo "All tests passed."
