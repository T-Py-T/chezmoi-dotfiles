#!/usr/bin/env bats

setup() {
  # shellcheck disable=SC2034
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  export CHEZMOI_SOURCE_DIR="${REPO_ROOT}"
  BREW_LOG="${BATS_TEST_TMPDIR}/brew.log"
  : >"$BREW_LOG"

  mkdir -p "${BATS_TEST_TMPDIR}/bin"
  cat >"${BATS_TEST_TMPDIR}/bin/brew" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"${BREW_LOG}"
exit 0
EOF
  chmod +x "${BATS_TEST_TMPDIR}/bin/brew"
  export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
}

@test "run_10_homebrew uses devcontainer Brewfile in containers" {
  run env DEVCONTAINER=1 PATH="${PATH}" bash "${REPO_ROOT}/scripts/run_10_homebrew"
  [ "$status" -eq 0 ]
  grep -Fq "bundle --file ${REPO_ROOT}/brew/devcontainer/dot_Brewfile.tmpl" "$BREW_LOG"
  ! grep -Fq 'brew update' "$BREW_LOG"
}

@test "run_10_homebrew selects macOS Brewfile on Darwin" {
  mkdir -p "${BATS_TEST_TMPDIR}/bin"
  cat >"${BATS_TEST_TMPDIR}/bin/uname" <<'EOF'
#!/usr/bin/env bash
echo Darwin
EOF
  chmod +x "${BATS_TEST_TMPDIR}/bin/uname"

  run env DEVCONTAINER=0 PATH="${BATS_TEST_TMPDIR}/bin:${PATH}" bash "${REPO_ROOT}/scripts/run_10_homebrew"
  [ "$status" -eq 0 ]
  grep -Fq "bundle install --file ${REPO_ROOT}/brew/macos/dot_Brewfile.tmpl" "$BREW_LOG"
  grep -Fx update "$BREW_LOG"
}
