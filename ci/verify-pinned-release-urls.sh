#!/usr/bin/env bash
# Verifies that checksum-pinned release URLs still resolve (CI dependency hygiene).
set -euo pipefail

list_file="${1:-$(dirname "$0")/pinned-release-urls.txt}"
failures=0

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  line="$(echo "$line" | xargs)"
  [ -z "$line" ] && continue

  if ! curl --fail --silent --show-error --head --location "$line" >/dev/null; then
    echo "Release URL not reachable: $line" >&2
    failures=$((failures + 1))
  fi
done < "$list_file"

if [ "$failures" -gt 0 ]; then
  echo "$failures pinned release URL(s) failed" >&2
  exit 1
fi

echo "All pinned release URLs responded."
