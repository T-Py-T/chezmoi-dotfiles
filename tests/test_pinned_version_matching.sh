#!/usr/bin/env bash
# Regression: pinned agent runtime versions must not match longer release strings.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

load_pinned_version_matches() {
  # shellcheck disable=SC1090
  eval "$(sed -n '/^pinned_version_matches()/,/^}/p' "$ROOT/scripts/run_after_20_agent_tools.tmpl")"
}

load_pinned_version_matches

assert_match() {
  local expected="$1"
  local output="$2"
  local label="$3"
  if pinned_version_matches "$expected" "$output"; then
    echo "ok   $label"
  else
    echo "FAIL: $label (expected match for '$expected' in '$output')" >&2
    failures=$((failures + 1))
  fi
}

assert_no_match() {
  local expected="$1"
  local output="$2"
  local label="$3"
  if pinned_version_matches "$expected" "$output"; then
    echo "FAIL: $label (unexpected match for '$expected' in '$output')" >&2
    failures=$((failures + 1))
  else
    echo "ok   $label"
  fi
}

assert_match "1.1.2" "bd version 1.1.2" "exact beads version matches"
assert_no_match "1.1.2" "bd version 1.1.20" "newer beads patch release does not match"
assert_match "17.2.10" "omp 17.2.10 (linux-x64)" "exact omp version matches"
assert_no_match "17.2.10" "omp 17.2.100" "longer omp version does not match"
assert_match "v0.20.0" "hermes v0.20.0 (2026.8.3)" "hermes tag matches"
assert_no_match "v0.20.0" "hermes v0.20.01 (2026.8.3)" "hermes pre-release suffix does not match"

if [ "$failures" -ne 0 ]; then
  echo "$failures test(s) failed" >&2
  exit 1
fi

echo "All pinned version matching tests passed."
