#!/usr/bin/env bats

setup() {
  # shellcheck disable=SC2034
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  if [ -z "${CHEZMOI_BIN:-}" ]; then
    CHEZMOI_BIN="$(command -v chezmoi || true)"
  fi
}

@test "run_once_before_setup respects SKIP_BREW" {
  run env SKIP_BREW=1 bash "${REPO_ROOT}/scripts/run_once_before_setup.tmpl"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping Homebrew setup"* ]]
}

@test "run_after_20_agent_tools renders as valid bash" {
  if [ -z "$CHEZMOI_BIN" ]; then
    skip "chezmoi not installed"
  fi
  rendered="${BATS_TEST_TMPDIR}/run_after_20_agent_tools.sh"
  "$CHEZMOI_BIN" execute-template --init <"${REPO_ROOT}/scripts/run_after_20_agent_tools.tmpl" >"$rendered"
  run bash -n "$rendered"
  [ "$status" -eq 0 ]
  grep -Fq 'readonly beads_version="1.1.2"' "$rendered"
}

@test "devcontainer Brewfile lists neovim and shellcheck" {
  grep -Fq 'brew "neovim"' "${REPO_ROOT}/brew/devcontainer/dot_Brewfile.tmpl"
  grep -Fq 'brew "shellcheck"' "${REPO_ROOT}/brew/devcontainer/dot_Brewfile.tmpl"
}
