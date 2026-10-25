#!/usr/bin/env bash
# run_once_before_setup.tmpl skip and non-install paths.

set -euo pipefail
# shellcheck source=tests/template_script_specs/lib/common.sh
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

script="$REPO_ROOT/scripts/run_once_before_setup.tmpl"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

output="$(assert_exit_code 0 env SKIP_BREW=1 bash "$script")"
assert_contains "$output" "Skipping Homebrew setup" "SKIP_BREW short-circuit"

fake_brew="$tmpdir/brew"
mkdir -p "$tmpdir/linuxbrew/.linuxbrew/bin"
ln -s "$fake_brew" "$tmpdir/linuxbrew/.linuxbrew/bin/brew"
cat >"$fake_brew" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  shellenv) printf 'export PATH="/fake-brew:$PATH"\n' ;;
  doctor) exit 1 ;;
  *) exit 0 ;;
esac
EOF
chmod +x "$fake_brew"

output="$(assert_exit_code 0 env PATH="$tmpdir/linuxbrew/.linuxbrew/bin:/usr/bin:/bin" bash "$script")"
assert_eq "$(printf '%s\n' "$output" | grep -c 'Skipping Homebrew setup' || true)" "0" "does not skip when brew exists"

output="$(assert_exit_code 0 env DEVCONTAINER=1 PATH="$tmpdir/linuxbrew/.linuxbrew/bin:/usr/bin:/bin" bash "$script")"
assert_eq "$(printf '%s\n' "$output" | grep -c 'brew doctor' || true)" "0" "no brew doctor in container"

finish_suite
