#!/usr/bin/env bash
# Coordination snippets export BD_DISABLE_METRICS=1.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/portable_guards/lib/common.sh
source "$here/lib/common.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export HOME="$tmpdir"

unset BD_DISABLE_METRICS || true
# shellcheck source=dot_config/bash/agent-coordination.bash
source "$ROOT/dot_config/bash/agent-coordination.bash"
assert_eq "1" "${BD_DISABLE_METRICS:-}" "bash coordination export"

unset BD_DISABLE_METRICS || true
# shellcheck source=dot_config/zsh/agent-coordination.zsh
source "$ROOT/dot_config/zsh/agent-coordination.zsh"
assert_eq "1" "${BD_DISABLE_METRICS:-}" "zsh coordination export"

echo "agent coordination env ok"
