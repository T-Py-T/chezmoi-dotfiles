#!/usr/bin/env bash
# startup.sh exits before heavy work when prerequisites are missing.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/portable_guards/lib/common.sh
source "$here/lib/common.sh"

startup="$ROOT/.devcontainer/startup.sh"

output="$(assert_exit_code 1 env -u CHEZMOI_SOURCE_DIR PATH=/usr/bin:/bin bash "$startup")"
assert_contains "$output" "mise is not installed" "missing mise"

fake_bin="$(mktemp -d)"
cat >"$fake_bin/mise" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$fake_bin/mise"

output="$(assert_exit_code 1 env CHEZMOI_SOURCE_DIR="$ROOT" PATH="$fake_bin:/usr/bin:/bin" bash "$startup")"
assert_contains "$output" "chezmoi is not installed" "missing chezmoi"

cat >"$fake_bin/chezmoi" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$fake_bin/chezmoi"

output="$(assert_exit_code 1 env -u CHEZMOI_SOURCE_DIR PATH="$fake_bin:/usr/bin:/bin" bash "$startup")"
assert_contains "$output" "CHEZMOI_SOURCE_DIR is not set" "missing source dir"

rm -rf "$fake_bin"

echo "devcontainer startup guards ok"
