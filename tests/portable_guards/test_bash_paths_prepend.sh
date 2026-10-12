#!/usr/bin/env bash
# bash 00-paths prepends ~/.local/bin once.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/portable_guards/lib/common.sh
source "$here/lib/common.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export HOME="$tmpdir"
mkdir -p "$HOME/.local/bin"

PATH="/usr/bin:/bin"
# shellcheck source=dot_config/bash/00-paths.bash
source "$ROOT/dot_config/bash/00-paths.bash"
first="${PATH%%:*}"
assert_eq "$HOME/.local/bin" "$first" "first PATH entry"

# shellcheck source=dot_config/bash/00-paths.bash
source "$ROOT/dot_config/bash/00-paths.bash"
count="$(tr ':' '\n' <<<"$PATH" | grep -c "$HOME/.local/bin" || true)"
assert_eq "1" "$count" "PATH should contain a single .local/bin entry"

echo "bash paths prepend ok"
