#!/usr/bin/env bash
# Run all tests under tests/unit/ locally (no GitHub Actions required).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UNIT="$ROOT/tests/unit"

export PYTHONPATH="$UNIT${PYTHONPATH:+:$PYTHONPATH}"

PYTEST="${PYTEST:-}"
if [ -z "$PYTEST" ]; then
  if command -v pytest >/dev/null 2>&1; then
    PYTEST=pytest
  elif [ -x "$HOME/.local/bin/pytest" ]; then
    PYTEST="$HOME/.local/bin/pytest"
  else
    echo "pytest is required (pip install pytest)" >&2
    exit 1
  fi
fi

echo "==> Python unit tests"
"$PYTEST" -q "$UNIT"

echo "==> Shell guard tests"
bash "$UNIT/test_shell_guards.sh"

echo "==> run_10_homebrew container regression"
bash "$UNIT/test_run_10_homebrew_container.sh"

echo "All tests/unit checks passed."
