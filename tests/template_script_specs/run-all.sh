#!/usr/bin/env bash
# Run template/script specification tests (local CI substitute).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

failures=0

run_shell_suite() {
  local suite="$1"
  echo "==> $suite"
  if bash "$suite"; then
    return 0
  fi
  failures=$((failures + 1))
  return 1
}

for suite in "$ROOT"/test_*.sh; do
  run_shell_suite "$suite" || true
done

echo "==> pytest (Python specs)"
if ! python3 -m pytest --version >/dev/null 2>&1; then
  python3 -m pip install --user pytest
fi
if PATH="${HOME}/.local/bin:${PATH}" python3 -m pytest -q "$ROOT"/test_*.py; then
  :
else
  failures=$((failures + 1))
fi

if [ "$failures" -gt 0 ]; then
  echo "FAILED: $failures suite(s)" >&2
  exit 1
fi

echo "All template/script specification tests passed."
