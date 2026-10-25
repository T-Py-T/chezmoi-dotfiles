#!/usr/bin/env bash
# Replicate check-nvim-health.sh counting logic against fixtures.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/portable_guards/lib/common.sh
source "$here/lib/common.sh"

fixtures="$here/fixtures"
count_errors() {
  local file="$1"
  LC_ALL=C strings "$file" | awk '/ERROR/{c++} END{print c+0}'
}

clean="$fixtures/nvim-health-clean.txt"
mixed="$fixtures/nvim-health-mixed.txt"

assert_eq "0" "$(count_errors "$clean")" "clean fixture"
assert_eq "2" "$(count_errors "$mixed")" "mixed fixture"

echo "nvim health counter logic ok"
