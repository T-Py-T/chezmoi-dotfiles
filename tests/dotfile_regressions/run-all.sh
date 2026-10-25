#!/usr/bin/env bash
# Run dotfile regression tests added on main (local CI substitute).

set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
failures=0

for test_script in "$here"/test_*.sh; do
  echo "==> $(basename "$test_script")"
  if ! bash "$test_script"; then
    failures=$((failures + 1))
  fi
done

if [ "$failures" -gt 0 ]; then
  echo "$failures test(s) failed" >&2
  exit 1
fi

echo "All dotfile regression tests passed."
