#!/usr/bin/env bash
# Shared helpers for script_behavior tests.

set -euo pipefail

script_behavior_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo_root="$(cd "${script_behavior_root}/../.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local label="${3:-output}"
  if ! printf '%s' "$haystack" | grep -Fq "$needle"; then
    echo "expected ${label} to contain: ${needle}" >&2
    printf '%s\n' "$haystack" >&2
    fail "${label} missing expected substring"
  fi
}

assert_exit() {
  local expected="$1"
  shift
  set +e
  local output
  output="$("$@" 2>&1)"
  local status=$?
  set -e
  if [ "$status" -ne "$expected" ]; then
    echo "expected exit ${expected}, got ${status} for: $*" >&2
    printf '%s\n' "$output" >&2
    fail "unexpected exit status"
  fi
  printf '%s' "$output"
}

render_chezmoi_source_dir() {
  local template="$1"
  local source_dir="$2"
  sed "s|{{ .chezmoi.sourceDir }}|${source_dir}|g" "$template"
}

ok() {
  echo "ok   $*"
}
