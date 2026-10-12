#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

bash tests/regression/test_run_once_before_setup.sh

python3 -m unittest discover -s tests/regression -p 'test_*.py' -v
