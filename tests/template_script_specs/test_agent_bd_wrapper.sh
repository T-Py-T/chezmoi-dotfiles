#!/usr/bin/env bash
# agent-bd wrapper: usage, sanitization, and actor forwarding.

set -euo pipefail
# shellcheck source=tests/template_script_specs/lib/common.sh
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

wrapper="$REPO_ROOT/dot_local/bin/executable_agent-bd"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

output="$(assert_exit_code 2 bash "${wrapper}")"
assert_contains "$output" "Usage: agent-bd" "usage without args"

output=$(assert_exit_code 2 bash "${wrapper}" omp worker ready)
assert_contains "$output" "Usage: agent-bd" "missing -- separator"

fake_bd="$tmpdir/bd"
cat >"$fake_bd" <<'EOF'
#!/usr/bin/env bash
printf 'actor=%s\n' "${BD_ACTOR:-}"
printf 'metrics=%s\n' "${BD_DISABLE_METRICS:-}"
printf 'args=%s\n' "$*"
EOF
chmod +x "$fake_bd"
export PATH="$tmpdir:$PATH"
export USER='test user!'
export BD_DISABLE_METRICS=0

host="$(hostname -s 2>/dev/null || hostname)"
output="$(assert_exit_code 0 bash "${wrapper}" 'omp harness' 'worker 01' -- ready --json)"
assert_contains "$output" "actor=test-user-@${host}:omp-harness:worker-01" "sanitized actor"
assert_contains "$output" "metrics=1" "metrics disabled for bd"
assert_contains "$output" "args=--actor" "forwards bd args"

output="$(assert_exit_code 127 env PATH=/usr/bin:/bin bash "${wrapper}" omp w1 -- ready)"
assert_contains "$output" "bd is not installed" "missing bd binary"

finish_suite
