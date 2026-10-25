#!/usr/bin/env bash
# run_10_homebrew devcontainer Brewfile selection and missing-file skip.

set -euo pipefail
# shellcheck source=tests/template_script_specs/lib/common.sh
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

script="$REPO_ROOT/scripts/run_10_homebrew"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

fake_brew="$tmpdir/brew"
cat >"$fake_brew" <<'EOF'
#!/usr/bin/env bash
printf 'brew:%s\n' "$*"
EOF
chmod +x "$fake_brew"
export PATH="$tmpdir:/usr/bin:/bin"

output="$(assert_exit_code 0 env DEVCONTAINER=1 CHEZMOI_SOURCE_DIR="$REPO_ROOT" bash "$script")"
assert_contains "$output" "Container environment detected" "container banner"
assert_contains "$output" "brew:bundle --file $REPO_ROOT/brew/devcontainer/dot_Brewfile.tmpl" "devcontainer brewfile"

missing_root="$(mktemp -d)"
output="$(assert_exit_code 0 env DEVCONTAINER=1 CHEZMOI_SOURCE_DIR="$missing_root" bash "$script")"
assert_contains "$output" "Devcontainer Brewfile not found" "missing brewfile tolerated"

finish_suite
