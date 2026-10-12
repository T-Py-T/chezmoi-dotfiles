#!/usr/bin/env bash
# .devcontainer/startup.sh should fail fast when required tooling is missing.

set -euo pipefail

# shellcheck source=lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

startup="${repo_root}/.devcontainer/startup.sh"

output="$(assert_exit 1 env -u PATH bash "$startup")"
assert_contains "$output" "mise is not installed" "missing mise"
ok "startup.sh requires mise"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/mise" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$tmpdir/mise"

output="$(assert_exit 1 env PATH="$tmpdir:$PATH" bash "$startup")"
assert_contains "$output" "chezmoi is not installed" "missing chezmoi"
ok "startup.sh requires chezmoi"

cat >"$tmpdir/chezmoi" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$tmpdir/chezmoi"

output="$(assert_exit 1 env PATH="$tmpdir:$PATH" bash "$startup")"
assert_contains "$output" "CHEZMOI_SOURCE_DIR is not set" "missing source dir"
ok "startup.sh requires CHEZMOI_SOURCE_DIR"
