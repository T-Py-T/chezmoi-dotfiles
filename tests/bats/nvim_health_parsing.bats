#!/usr/bin/env bats

load common

setup() {
  FIXTURES="${BATS_TEST_DIRNAME}/../fixtures"
}

@test "health summary awk counts zero errors on clean fixture" {
  count="$(health_error_count "${FIXTURES}/nvim-health-clean.txt")"
  [ "$count" -eq 0 ]
}

@test "health summary awk counts errors on failing fixture" {
  count="$(health_error_count "${FIXTURES}/nvim-health-errors.txt")"
  [ "$count" -eq 1 ]
}
