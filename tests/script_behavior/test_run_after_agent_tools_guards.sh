#!/usr/bin/env bash
# Early-exit guards in scripts/run_after_20_agent_tools.tmpl (no downloads).

set -euo pipefail

# shellcheck source=lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

template="${repo_root}/scripts/run_after_20_agent_tools.tmpl"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

render_chezmoi_source_dir "$template" "$repo_root" >"$tmpdir/rendered.sh"
chmod +x "$tmpdir/rendered.sh"

output="$(assert_exit 0 env SKIP_AGENT_TOOLS=1 bash "$tmpdir/rendered.sh")"
assert_contains "$output" "Skipping agent runtimes" "skip env"
ok "run_after_20_agent_tools honors SKIP_AGENT_TOOLS"

output="$(assert_exit 0 env DEVCONTAINER=1 bash "$tmpdir/rendered.sh")"
assert_contains "$output" "Skipping workstation agent runtimes" "container skip"
ok "run_after_20_agent_tools skips in containers"
