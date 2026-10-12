#!/usr/bin/env bash
# mise chezmoi tasks refuse to run without CHEZMOI_SOURCE_DIR.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/portable_guards/lib/common.sh
source "$here/lib/common.sh"

for task in init apply; do
  script="$ROOT/.mise/tasks/chezmoi/$task"
  output="$(assert_exit_code 1 env -u CHEZMOI_SOURCE_DIR bash "$script")"
  assert_contains "$output" "CHEZMOI_SOURCE_DIR is not set" "task $task"
done

echo "mise chezmoi task guards ok"
