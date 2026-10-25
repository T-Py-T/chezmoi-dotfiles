#!/usr/bin/env bash
# run_after_20_agent_tools.tmpl environment guards (no downloads).

set -euo pipefail
# shellcheck source=tests/template_script_specs/lib/common.sh
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

rendered="$REPO_ROOT/scripts/run_after_20_agent_tools.tmpl"
# Chezmoi template token: substitute a real path for static analysis runs.
script="$(mktemp)"
trap 'rm -f "$script"' EXIT
sed "s|{{ .chezmoi.sourceDir }}|$REPO_ROOT|g" "$rendered" >"$script"
chmod +x "$script"

output="$(assert_exit_code 0 env SKIP_AGENT_TOOLS=1 bash "$script")"
assert_contains "$output" "Skipping agent runtimes" "SKIP_AGENT_TOOLS"

output="$(assert_exit_code 0 env DEVCONTAINER=1 bash "$script")"
assert_contains "$output" "Skipping workstation agent runtimes" "container skip"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
fake_uname="$tmpdir/uname"
cat >"$fake_uname" <<'EOF'
#!/usr/bin/env bash
echo FreeBSD
EOF
chmod +x "$fake_uname"
export PATH="$tmpdir:/usr/bin:/bin"

output="$(assert_exit_code 0 bash "$script")"
assert_contains "$output" "not configured for FreeBSD" "unsupported kernel"

finish_suite
