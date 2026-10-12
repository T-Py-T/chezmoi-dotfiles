#!/usr/bin/env bash
# Early-exit paths in .devcontainer/startup.sh (no full container bootstrap).

set -euo pipefail
# shellcheck source=tests/template_script_specs/lib/common.sh
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

startup="$REPO_ROOT/.devcontainer/startup.sh"

output="$(assert_exit_code 1 env -u CHEZMOI_SOURCE_DIR PATH=/usr/bin:/bin bash "$startup")"
assert_contains "$output" "mise is not installed" "missing mise"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

fake_mise="$tmpdir/mise"
cat >"$fake_mise" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$fake_mise"

output="$(assert_exit_code 1 env CHEZMOI_SOURCE_DIR="$REPO_ROOT" PATH="$tmpdir:/usr/bin:/bin" bash "$startup")"
assert_contains "$output" "chezmoi is not installed" "missing chezmoi"

fake_chezmoi="$tmpdir/chezmoi"
cat >"$fake_chezmoi" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$fake_chezmoi"

output="$(assert_exit_code 1 env -u CHEZMOI_SOURCE_DIR PATH="$tmpdir:/usr/bin:/bin" bash "$startup")"
assert_contains "$output" "CHEZMOI_SOURCE_DIR is not set" "missing source dir"

finish_suite
