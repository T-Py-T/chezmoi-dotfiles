# Shared helpers for gap-coverage bats tests (kept separate from PR #25 tests/bats/common.bash).

GAP_REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../../.." && pwd)"

gap_repo_root() {
  printf '%s' "$GAP_REPO_ROOT"
}

# Render a chezmoi script template when chezmoi is available; otherwise substitute sourceDir.
gap_render_script() {
  local template_path="$1"
  local output_path="$2"
  local source_dir="${3:-$GAP_REPO_ROOT}"

  if command -v chezmoi >/dev/null 2>&1; then
    chezmoi execute-template --init <"$template_path" >"$output_path"
    return 0
  fi

  sed "s|{{ .chezmoi.sourceDir }}|${source_dir}|g" "$template_path" >"$output_path"
}
