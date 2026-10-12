#!/usr/bin/env bash
# scripts/validate-shell-scripts.sh
# Syntax-check and shellcheck static shell scripts (non-template sources).
# Chezmoi .tmpl bootstrap scripts are validated after rendering in validate-chezmoi-templates.sh.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
shellcheck_bin="${SHELLCHECK_BIN:-shellcheck}"

if ! command -v "$shellcheck_bin" >/dev/null 2>&1; then
  echo "shellcheck not found (set SHELLCHECK_BIN or install shellcheck)" >&2
  exit 1
fi

mapfile -t files < <(
  find "$repo_root/scripts" -maxdepth 1 \( -name '*.sh' -o -name 'run_10_homebrew' \) -print
  find "$repo_root/dot_local/bin" -name 'executable_*' -print 2>/dev/null || true
  printf '%s\n' "$repo_root/.devcontainer/startup.sh"
)

failures=0
for file in "${files[@]}"; do
  [ -f "$file" ] || continue
  printf 'Checking %s\n' "${file#"$repo_root"/}"
  if ! bash -n "$file"; then
    printf 'FAIL: bash -n %s\n' "$file" >&2
    failures=$((failures + 1))
    continue
  fi
  if ! "$shellcheck_bin" -S warning --shell=bash "$file"; then
    printf 'FAIL: shellcheck %s\n' "$file" >&2
    failures=$((failures + 1))
  fi
done

if [ "$failures" -gt 0 ]; then
  printf '%d static shell script failure(s)\n' "$failures" >&2
  exit 1
fi

printf 'All static shell script checks passed.\n'
