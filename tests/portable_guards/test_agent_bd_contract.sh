#!/usr/bin/env bash
# agent-bd validates argv shape before requiring bd on PATH.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/portable_guards/lib/common.sh
source "$here/lib/common.sh"

wrapper="$ROOT/dot_local/bin/executable_agent-bd"

output="$(assert_exit_code 2 bash "$wrapper")"
assert_contains "$output" "Usage: agent-bd" "missing args"

output="$(assert_exit_code 2 bash "$wrapper" harness worker ready)"
assert_contains "$output" "Usage: agent-bd" "missing separator"

fake_bin="$(mktemp -d)"
trap 'rm -rf "$fake_bin"' EXIT
cat >"$fake_bin/bd" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*"
EOF
chmod +x "$fake_bin/bd"

output="$(env PATH="$fake_bin:/usr/bin:/bin" bash "$wrapper" 'harness!!' 'worker id' -- ready --json)"
assert_contains "$output" "--actor" "bd invoked"
assert_contains "$output" "harness-:worker-id" "sanitized harness and worker id"

echo "agent-bd contract ok"
