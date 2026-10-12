#!/usr/bin/env bash
# Guards and early-exit behavior for bootstrap shell entrypoints.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
failures=0

assert_exit() {
  local expected="$1"
  local label="$2"
  shift 2
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  if [ "$code" -ne "$expected" ]; then
    echo "FAIL: $label (expected exit $expected, got $code)" >&2
    failures=$((failures + 1))
  else
    echo "ok   $label"
  fi
}

assert_contains() {
  local needle="$1"
  local label="$2"
  shift 2
  local output
  output="$("$@" 2>&1)"
  if ! printf '%s' "$output" | grep -Fq "$needle"; then
    echo "FAIL: $label (missing '$needle')" >&2
    failures=$((failures + 1))
  else
    echo "ok   $label"
  fi
}

for task in init apply dry-run; do
  assert_exit 1 "mise chezmoi:$task requires CHEZMOI_SOURCE_DIR" \
    env -u CHEZMOI_SOURCE_DIR bash "$ROOT/.mise/tasks/chezmoi/$task"
done

assert_exit 1 "startup.sh requires mise" \
  env -u DEVCONTAINER PATH=/usr/bin:/bin CHEZMOI_SOURCE_DIR=/tmp bash "$ROOT/.devcontainer/startup.sh"

if command -v chezmoi >/dev/null 2>&1; then
  assert_exit 1 "startup.sh requires CHEZMOI_SOURCE_DIR when mise+chezmoi exist" \
    env DEVCONTAINER=1 PATH="$PATH" bash "$ROOT/.devcontainer/startup.sh"
else
  echo "skip startup CHEZMOI_SOURCE_DIR check (chezmoi not installed)"
fi

assert_contains "Skipping Homebrew setup" "run_once_before_setup honors SKIP_BREW" \
  env SKIP_BREW=1 bash "$ROOT/scripts/run_once_before_setup.tmpl"

if [ "$failures" -gt 0 ]; then
  echo "$failures guard test(s) failed" >&2
  exit 1
fi

echo "All shell guard tests passed."
