#!/usr/bin/env bash
# Regression tests for shell config bugs not covered by open draft PRs #23–#30.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

failures=0

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"
  if ! grep -Fq "$needle" "$file"; then
    echo "FAIL: $label — expected $file to contain: $needle" >&2
    failures=$((failures + 1))
  else
    echo "ok   $label"
  fi
}

assert_ls_alias_uses_eza_when_available() {
  local tmp
  tmp="$(mktemp -d)"
  # shellcheck disable=SC1090
  (
    set -euo pipefail
    export PATH="$tmp:$PATH"
    printf '#!/bin/sh\n' > "$tmp/eza"
    printf 'exit 0\n' >> "$tmp/eza"
    chmod +x "$tmp/eza"
    # shellcheck source=dot_config/shell_aliases
    source "$repo_root/dot_config/shell_aliases"
    alias ls | grep -Fq "eza --icons=auto"
  ) && echo "ok   shell_aliases prefers eza for ls when eza is on PATH" || {
    echo "FAIL: shell_aliases should alias ls to eza when eza is available" >&2
    failures=$((failures + 1))
  }
  rm -rf "$tmp"
}

assert_fzf_prefix_loop_covers_linuxbrew_and_intel() {
  local fzf_file="$repo_root/dot_config/zsh/fzf.zsh"
  assert_contains "$fzf_file" "/usr/local/opt/fzf" "fzf.zsh Intel Homebrew prefix"
  assert_contains "$fzf_file" "/home/linuxbrew/.linuxbrew/opt/fzf" "fzf.zsh Linuxbrew prefix"
}

assert_fzf_prefix_loop_covers_linuxbrew_and_intel
assert_ls_alias_uses_eza_when_available

if [ "$failures" -ne 0 ]; then
  echo "$failures test(s) failed" >&2
  exit 1
fi

echo "All shell config regression tests passed."
