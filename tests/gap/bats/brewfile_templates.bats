#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/support.bash"

setup() {
  REPO_ROOT="$GAP_REPO_ROOT"
}

@test "linux Brewfile installs mise and pre-commit" {
  local brewfile="${REPO_ROOT}/brew/linux/dot_Brewfile.tmpl"
  grep -Fq 'brew "mise"' "$brewfile"
  grep -Fq 'brew "pre-commit"' "$brewfile"
  grep -Fq 'brew "neovim"' "$brewfile"
}

@test "WSL Brewfile is a superset of shared Linux tooling" {
  local base="${REPO_ROOT}/brew/linux/dot_Brewfile.tmpl"
  local wsl="${REPO_ROOT}/brew/linux/dot_Brewfile-wsl.tmpl"
  grep -Fq 'brew "neovim"' "$wsl"
  grep -Fq 'tap "can1357/tap"' "$wsl"
  grep -Fq 'brew "mise"' "$base"
  grep -Fq 'brew "mise"' "$wsl"
}

@test "macOS Brewfile includes GUI casks and mise" {
  local brewfile="${REPO_ROOT}/brew/macos/dot_Brewfile.tmpl"
  grep -Fq 'brew "mise"' "$brewfile"
  grep -Eq '^cask ' "$brewfile"
  grep -Fq 'brew "neovim"' "$brewfile"
}

@test "macOS Work Brewfile layers extra taps" {
  local work="${REPO_ROOT}/brew/macos/dot_Brewfile-Work.tmpl"
  grep -Fq 'brew "ansible"' "$work"
  grep -Fq 'tap "defenseunicorns/tap"' "$work"
}

@test "run_10_homebrew documents WSL Brewfile selection" {
  grep -Fq 'dot_Brewfile-wsl.tmpl' "${REPO_ROOT}/scripts/run_10_homebrew"
  grep -Fq 'dot_Brewfile.tmpl' "${REPO_ROOT}/scripts/run_10_homebrew"
}
