#!/usr/bin/env bash
# Run all script_behavior regression tests.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failed=0

for test_script in "$root"/test_*.sh; do
  echo "==> $(basename "$test_script")"
  if bash "$test_script"; then
    echo
  else
    failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  echo "script_behavior suite failed" >&2
  exit 1
fi

echo "script_behavior suite passed"
