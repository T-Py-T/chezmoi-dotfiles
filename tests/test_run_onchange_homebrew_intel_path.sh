#!/usr/bin/env bash
# Regression: pre-commit hook install runs in the same minimal chezmoi script
# environment as run_10_homebrew and must activate Intel macOS Homebrew (/usr/local).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="${ROOT}/scripts/run_onchange_after_precommit.tmpl"
HOMEBREW_SCRIPT="${ROOT}/scripts/run_10_homebrew"
failures=0

assert_contains() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if grep -Fq "$needle" "$file"; then
    echo "ok   $label"
  else
    echo "FAIL: $label (missing in $file)" >&2
    failures=$((failures + 1))
  fi
}

assert_contains '/usr/local/bin/brew' "$TEMPLATE" "Intel Homebrew path present in precommit template"
assert_contains '/usr/local/bin/brew' "$HOMEBREW_SCRIPT" "Intel Homebrew path present in run_10_homebrew (reference)"

# Executable checks: a non-executable brew shim must not be sourced.
assert_contains '[ -x /home/linuxbrew/.linuxbrew/bin/brew ]' "$TEMPLATE" "linuxbrew uses -x test"
assert_contains '[ -x /opt/homebrew/bin/brew ]' "$TEMPLATE" "Apple Silicon brew uses -x test"
assert_contains '[ -x /usr/local/bin/brew ]' "$TEMPLATE" "Intel brew uses -x test"

# Order must match run_10_homebrew so the first working install wins.
linuxbrew_line="$(grep -n 'linuxbrew/bin/brew' "$TEMPLATE" | head -1 | cut -d: -f1)"
opt_line="$(grep -n '/opt/homebrew/bin/brew' "$TEMPLATE" | head -1 | cut -d: -f1)"
intel_line="$(grep -n '/usr/local/bin/brew' "$TEMPLATE" | head -1 | cut -d: -f1)"
if [ -n "$linuxbrew_line" ] && [ -n "$opt_line" ] && [ -n "$intel_line" ] &&
  [ "$linuxbrew_line" -lt "$opt_line" ] && [ "$opt_line" -lt "$intel_line" ]; then
  echo "ok   Homebrew path precedence (linuxbrew, opt, usr/local)"
else
  echo "FAIL: unexpected Homebrew path order in $TEMPLATE" >&2
  failures=$((failures + 1))
fi

if [ "$failures" -ne 0 ]; then
  echo "$failures test(s) failed" >&2
  exit 1
fi

echo "All run_onchange Homebrew path tests passed."
