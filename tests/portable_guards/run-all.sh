#!/usr/bin/env bash
# Run portable guard tests (no edits to production files).

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/portable_guards/lib/common.sh
source "$here/lib/common.sh"

failures=0
ran=0

run_test() {
  local script="$1"
  ran=$((ran + 1))
  echo "==> $(basename "$script")"
  if bash "$script"; then
    echo "    ok"
  else
    echo "    FAIL"
    failures=$((failures + 1))
  fi
}

for script in "$here"/test_*.sh; do
  [ -f "$script" ] || continue
  run_test "$script"
done

for script in "$here"/test_*.py; do
  [ -f "$script" ] || continue
  ran=$((ran + 1))
  echo "==> $(basename "$script")"
  if python3 "$script"; then
    echo "    ok"
  else
    echo "    FAIL"
    failures=$((failures + 1))
  fi
done

echo ""
echo "Ran $ran test file(s); $failures failure(s)."
[ "$failures" -eq 0 ]
