#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/support.bash"

setup() {
  REPO_ROOT="$GAP_REPO_ROOT"
}

@test "run_onchange_after_precommit skips in devcontainer" {
  run env DEVCONTAINER=1 bash "${REPO_ROOT}/scripts/run_onchange_after_precommit.tmpl"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Container detected"* ]]
}

@test "run_onchange_after_precommit documents dockerenv container guard" {
  grep -Fq '/.dockerenv' "${REPO_ROOT}/scripts/run_onchange_after_precommit.tmpl"
  grep -Fq 'Container detected' "${REPO_ROOT}/scripts/run_onchange_after_precommit.tmpl"
}

@test "run_onchange_after_precommit exits cleanly when pre-commit is missing" {
  run env PATH=/usr/bin:/bin bash "${REPO_ROOT}/scripts/run_onchange_after_precommit.tmpl"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pre-commit not found"* ]]
}

@test "run_onchange_after_precommit skips hook install outside git source" {
  local src="${BATS_TEST_TMPDIR}/chezmoi-src"
  local stub_dir="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "$src" "$stub_dir"
  printf 'repos:\n' >"$src/.pre-commit-config.yaml"
  printf '#!/usr/bin/env bash\nexit 0\n' >"$stub_dir/pre-commit"
  chmod +x "$stub_dir/pre-commit"
  local rendered="${BATS_TEST_TMPDIR}/run_onchange.sh"
  gap_render_script "${REPO_ROOT}/scripts/run_onchange_after_precommit.tmpl" "$rendered" "$src"
  run env PATH="$stub_dir:/usr/bin:/bin" bash "$rendered"
  [ "$status" -eq 0 ]
  [[ "$output" == *"not a git repo"* ]]
}

@test "run_onchange_after_precommit renders as valid bash" {
  local rendered="${BATS_TEST_TMPDIR}/run_onchange.sh"
  gap_render_script "${REPO_ROOT}/scripts/run_onchange_after_precommit.tmpl" "$rendered"
  run bash -n "$rendered"
  [ "$status" -eq 0 ]
}
