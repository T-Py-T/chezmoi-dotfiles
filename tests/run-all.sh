#!/usr/bin/env bash
# Run repository unit tests (Python + bats). Used locally and in CI.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

python_bin="${PYTHON:-python3}"
if ! command -v "$python_bin" >/dev/null 2>&1; then
  echo "python3 is required to run tests" >&2
  exit 1
fi

if ! "$python_bin" -c "import yaml" 2>/dev/null; then
  echo "PyYAML is required (pip install pyyaml)" >&2
  exit 1
fi

echo "==> Python tests"
"$python_bin" -m unittest discover -s tests/python -p 'test_*.py' -v

if command -v bats >/dev/null 2>&1; then
  echo "==> bats tests"
  bats tests/bats
else
  echo "bats is not installed; skipping shell tests" >&2
  exit 1
fi

echo "All tests passed."
