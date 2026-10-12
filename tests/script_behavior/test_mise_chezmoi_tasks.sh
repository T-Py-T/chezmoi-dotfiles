#!/usr/bin/env bash
# Behavioral checks for .mise/tasks/chezmoi/* guard rails.

set -euo pipefail

# shellcheck source=lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/chezmoi" <<'EOF'
#!/usr/bin/env bash
echo "chezmoi:$*"
EOF
chmod +x "$tmpdir/chezmoi"

for task in init apply dry-run; do
  task_path="${repo_root}/.mise/tasks/chezmoi/${task}"
  output="$(assert_exit 1 env -u CHEZMOI_SOURCE_DIR bash "$task_path")"
  assert_contains "$output" "CHEZMOI_SOURCE_DIR is not set" "task ${task}"

  output="$(assert_exit 0 env CHEZMOI_SOURCE_DIR="$repo_root" PATH="$tmpdir:$PATH" bash "$task_path")"
  case "$task" in
    init)
      assert_contains "$output" "chezmoi:init --source ${repo_root}" "task init"
      ;;
    apply)
      assert_contains "$output" "chezmoi:apply --source ${repo_root}" "task apply"
      ;;
    dry-run)
      assert_contains "$output" "chezmoi:apply --dry-run --source ${repo_root}" "task dry-run"
      ;;
  esac
  ok "mise chezmoi:${task} forwards source dir"
done
