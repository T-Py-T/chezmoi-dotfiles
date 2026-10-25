#!/usr/bin/env bash
# Chezmoi run_ scripts honor skip flags and container short-circuits.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/portable_guards/lib/common.sh
source "$here/lib/common.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export HOME="$tmpdir"
mkdir -p "$tmpdir/.dockerenv"

once="$ROOT/scripts/run_once_before_setup.tmpl"
output="$(assert_exit_code 0 env SKIP_BREW=1 bash "$once")"
assert_contains "$output" "Skipping Homebrew setup" "run_once SKIP_BREW"

onchange="$ROOT/scripts/run_onchange_after_precommit.tmpl"
output="$(assert_exit_code 0 env DEVCONTAINER=1 bash "$onchange")"
assert_contains "$output" "Container detected" "run_onchange container skip"

after="$ROOT/scripts/run_after_20_agent_tools.tmpl"
output="$(assert_exit_code 0 env SKIP_AGENT_TOOLS=1 bash "$after")"
assert_contains "$output" "Skipping agent runtimes" "run_after SKIP_AGENT_TOOLS"

output="$(assert_exit_code 0 env DEVCONTAINER=1 bash "$after")"
assert_contains "$output" "Skipping workstation agent runtimes" "run_after container skip"

echo "run script guards ok"
