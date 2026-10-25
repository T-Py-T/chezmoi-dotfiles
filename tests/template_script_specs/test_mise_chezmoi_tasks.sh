#!/usr/bin/env bash
# Guards on mise chezmoi task wrappers (.mise/tasks/chezmoi/*).

set -euo pipefail
# shellcheck source=tests/template_script_specs/lib/common.sh
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

for task in init apply dry-run; do
  task_path="$REPO_ROOT/.mise/tasks/chezmoi/$task"
  output="$(assert_exit_code 1 env -u CHEZMOI_SOURCE_DIR bash "$task_path")"
  assert_contains "$output" "CHEZMOI_SOURCE_DIR is not set" "task $task"
done

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export CHEZMOI_SOURCE_DIR="$tmpdir"

fake_chezmoi="$tmpdir/chezmoi"
cat >"$fake_chezmoi" <<'EOF'
#!/usr/bin/env bash
printf 'chezmoi:%s\n' "$*"
EOF
chmod +x "$fake_chezmoi"
export PATH="$tmpdir:$PATH"

output="$(assert_exit_code 0 bash "${REPO_ROOT}/.mise/tasks/chezmoi/dry-run")"
assert_contains "$output" "apply --dry-run --source ${tmpdir}" "dry-run forwards flags"

output="$(assert_exit_code 0 bash "${REPO_ROOT}/.mise/tasks/chezmoi/init")"
assert_contains "$output" "init --source ${tmpdir}" "init uses source dir"

output="$(assert_exit_code 0 bash "${REPO_ROOT}/.mise/tasks/chezmoi/apply")"
assert_contains "$output" "apply --source ${tmpdir}" "apply uses source dir"

finish_suite
