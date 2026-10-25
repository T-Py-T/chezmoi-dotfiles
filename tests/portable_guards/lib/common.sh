#!/usr/bin/env bash
# Shared helpers for portable_guards tests.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="${3:-}"
  if [ "$expected" != "$actual" ]; then
    echo "ASSERT_EQ failed${message:+: $message}" >&2
    echo "  expected: $expected" >&2
    echo "  actual:   $actual" >&2
    return 1
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="${3:-}"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "ASSERT_CONTAINS failed${message:+: $message}" >&2
    echo "  needle:   $needle" >&2
    echo "  haystack: $haystack" >&2
    return 1
  fi
}

assert_exit_code() {
  local expected="$1"
  shift
  set +e
  local output
  output="$("$@" 2>&1)"
  local code=$?
  set -e
  if [ "$code" -ne "$expected" ]; then
    echo "ASSERT_EXIT_CODE failed: expected $expected got $code for: $*" >&2
    echo "$output" >&2
    return 1
  fi
  printf '%s' "$output"
}
