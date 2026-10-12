#!/usr/bin/env bash
# scripts/devpod-up.sh should orchestrate delete + up --reset for a workspace id.

set -euo pipefail

# shellcheck source=lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/devpod" <<'EOF'
#!/usr/bin/env bash
echo "devpod:$*"
EOF
chmod +x "$tmpdir/devpod"

log="$tmpdir/devpod.log"
output="$(
  env PATH="$tmpdir:$PATH" bash "$repo_root/scripts/devpod-up.sh" my-workspace 2>&1 | tee "$log"
)"

assert_contains "$output" "my-workspace" "devpod-up banner"
assert_contains "$(cat "$log")" "devpod:delete my-workspace --force" "delete call"
assert_contains "$(cat "$log")" "devpod:up . --reset --id my-workspace" "up call"
ok "devpod-up.sh delete and reset workspace"

default_output="$(
  env PATH="$tmpdir:$PATH" bash "$repo_root/scripts/devpod-up.sh" 2>&1
)"
assert_contains "$default_output" "devpod:up . --reset --id dev" "default workspace id"
ok "devpod-up.sh default workspace id"
