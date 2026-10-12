#!/usr/bin/env bash
# scripts/test_bootstrap_scripts.sh
# Lightweight behavioral tests for repo shell helpers (no network, no agent downloads).

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

assert_exit() {
  local expected="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local actual=$?
  set -e
  if [ "$actual" -ne "$expected" ]; then
    printf 'FAIL: expected exit %s from %s, got %s\n' "$expected" "$*" "$actual" >&2
    failures=$((failures + 1))
  fi
}

assert_contains() {
  local needle="$1"
  local haystack="$2"
  if ! printf '%s' "$haystack" | grep -Fq -- "$needle"; then
    printf 'FAIL: output missing %q\n' "$needle" >&2
    failures=$((failures + 1))
  fi
}

printf 'test_agent_bd_usage_requires_delimiter\n'
assert_exit 2 bash "$repo_root/dot_local/bin/executable_agent-bd"
assert_exit 2 bash "$repo_root/dot_local/bin/executable_agent-bd" omp worker-01 ready

printf 'test_agent_bd_sets_actor_and_forwards_args\n'
stub_bin="$(mktemp -d)"
trap 'rm -rf "$stub_bin"' EXIT
cat > "$stub_bin/bd" <<'EOF'
#!/usr/bin/env bash
printf 'actor=%s\n' "${BD_ACTOR:-}"
printf 'metrics=%s\n' "${BD_DISABLE_METRICS:-}"
printf 'args=%s\n' "$*"
EOF
chmod +x "$stub_bin/bd"

output="$(PATH="$stub_bin:$PATH" bash "$repo_root/dot_local/bin/executable_agent-bd" omp worker-01 -- ready --claim --json)"
assert_contains 'actor=' "$output"
assert_contains 'metrics=1' "$output"
assert_contains 'ready --claim --json' "$output"
assert_contains '--actor' "$output"
assert_contains '@' "$output"
assert_contains ':omp:worker-01' "$output"

if [ "$failures" -gt 0 ]; then
  printf '%d bootstrap script test failure(s)\n' "$failures" >&2
  exit 1
fi

printf 'All bootstrap script tests passed.\n'
