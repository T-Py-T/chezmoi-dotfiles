#!/usr/bin/env bash
# devpod-up.sh workspace id handling without calling real devpod.

set -euo pipefail
# shellcheck source=tests/template_script_specs/lib/common.sh
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

script="$REPO_ROOT/scripts/devpod-up.sh"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

fake_devpod="$tmpdir/devpod"
cat >"$fake_devpod" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*"
EOF
chmod +x "$fake_devpod"
export PATH="$tmpdir:$PATH"

output="$(assert_exit_code 0 bash "$script")"
assert_contains "$output" "delete dev --force" "default workspace id"
assert_contains "$output" "up . --reset --id dev" "default up id"

output="$(assert_exit_code 0 bash "$script" my-ws)"
assert_contains "$output" "delete my-ws --force" "custom workspace id"
assert_contains "$output" "up . --reset --id my-ws" "custom up id"

finish_suite
