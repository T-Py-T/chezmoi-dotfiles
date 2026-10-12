#!/usr/bin/env bash
# Behavioral checks for scripts/run_onchange_after_precommit.tmpl

set -euo pipefail

# shellcheck source=lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

template="${repo_root}/scripts/run_onchange_after_precommit.tmpl"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

render_script() {
  local source_dir="$1"
  render_chezmoi_source_dir "$template" "$source_dir" >"$tmpdir/rendered.sh"
  chmod +x "$tmpdir/rendered.sh"
}

render_script "$tmpdir/fake-src"
output="$(assert_exit 0 env DEVCONTAINER=1 bash "$tmpdir/rendered.sh")"
assert_contains "$output" "Container detected" "container skip"
ok "run_onchange skips in devcontainer"

cat >"$tmpdir/pre-commit" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$tmpdir/pre-commit"

render_script "$tmpdir/no-git"
output="$(
  assert_exit 0 env -u DEVCONTAINER PATH="$tmpdir:$PATH" bash "$tmpdir/rendered.sh"
)"
assert_contains "$output" "not a git repo" "missing git metadata"
ok "run_onchange no-ops without chezmoi source git repo"

mkdir -p "$tmpdir/with-git/.git"
cp "$repo_root/.pre-commit-config.yaml" "$tmpdir/with-git/"
render_script "$tmpdir/with-git"

output="$(assert_exit 0 env -u DEVCONTAINER bash "$tmpdir/rendered.sh")"
assert_contains "$output" "pre-commit not found" "missing pre-commit binary"
ok "run_onchange skips when pre-commit is absent"

cat >"$tmpdir/pre-commit" <<'EOF'
#!/usr/bin/env bash
echo "pre-commit:$*"
EOF
chmod +x "$tmpdir/pre-commit"

output="$(
  assert_exit 0 env -u DEVCONTAINER PATH="$tmpdir:$PATH" bash "$tmpdir/rendered.sh"
)"
assert_contains "$output" "pre-commit:install" "hook install"
assert_contains "$output" "pre-commit:install-hooks" "hook env warm-up"
ok "run_onchange installs hooks when pre-commit is available"
