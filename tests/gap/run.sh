#!/usr/bin/env bash
# Runs gap-coverage tests only (complements draft PR #25 without touching its paths).

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

python_bin="${PYTHON:-python3}"
if ! command -v "$python_bin" >/dev/null 2>&1; then
  echo "python3 is required" >&2
  exit 1
fi

if ! "$python_bin" -c "import yaml" 2>/dev/null; then
  echo "PyYAML is required (pip install pyyaml)" >&2
  exit 1
fi

echo "==> Python gap tests"
"$python_bin" -m unittest discover -s tests/gap/python -p 'test_*.py' -v

if ! command -v bats >/dev/null 2>&1; then
  echo "bats is required (install bats-core)" >&2
  exit 1
fi

echo "==> bats gap tests"
bats tests/gap/bats

echo "All gap tests passed."
