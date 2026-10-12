#!/usr/bin/env bash
# Every .chezmoiignore entry should exist in the repo; dot_ targets must not be ignored.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/portable_guards/lib/common.sh
source "$here/lib/common.sh"

ignore_file="$ROOT/.chezmoiignore"
[ -f "$ignore_file" ] || { echo "missing .chezmoiignore" >&2; exit 1; }

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [ -z "$line" ] && continue
  target="$ROOT/$line"
  if [ ! -e "$target" ]; then
    echo "chezmoiignore references missing path: $line" >&2
    exit 1
  fi
done < "$ignore_file"

# Representative home targets must remain managed by chezmoi.
for managed in dot_zshrc dot_config/starship.toml scripts/run_10_homebrew; do
  if grep -Fxq "$managed" "$ignore_file"; then
    echo "unexpected chezmoiignore entry for managed target: $managed" >&2
    exit 1
  fi
done

echo "chezmoiignore contract ok"
