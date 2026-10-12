#!/usr/bin/env bash
# Shared helpers for template/script specification tests.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
export REPO_ROOT

TESTS_RUN=0
TESTS_FAILED=0

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="${3:-}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ "$expected" = "$actual" ]; then
    return 0
  fi
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo "ASSERT_EQ failed${message:+ ($message)}: expected '$expected', got '$actual'" >&2
  return 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="${3:-}"
  TESTS_RUN=$((TESTS_RUN + 1))
  if printf '%s' "$haystack" | grep -Fq -- "$needle"; then
    return 0
  fi
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo "ASSERT_CONTAINS failed${message:+ ($message)}: missing '$needle'" >&2
  return 1
}

assert_exit_code() {
  local expected="$1"
  shift
  local output
  local actual
  TESTS_RUN=$((TESTS_RUN + 1))
  set +e
  output="$("$@" 2>&1)"
  actual=$?
  set -e
  if [ "$actual" -eq "$expected" ]; then
    printf '%s' "$output"
    return 0
  fi
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo "ASSERT_EXIT_CODE failed: expected exit $expected, got $actual" >&2
  echo "Output: $output" >&2
  return 1
}

finish_suite() {
  if [ "$TESTS_FAILED" -gt 0 ]; then
    echo "${BASH_SOURCE[1]##*/}: $TESTS_FAILED failure(s) in $TESTS_RUN assertion(s)" >&2
    exit 1
  fi
  echo "${BASH_SOURCE[1]##*/}: ok ($TESTS_RUN assertions)"
}
