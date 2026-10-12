#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/support.bash"

setup() {
  REPO_ROOT="$GAP_REPO_ROOT"
}

@test "run_after_20_agent_tools honors SKIP_AGENT_TOOLS" {
  run env SKIP_AGENT_TOOLS=1 bash "${REPO_ROOT}/scripts/run_after_20_agent_tools.tmpl"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping agent runtimes"* ]]
}

@test "run_after_20_agent_tools skips in container environments" {
  run env DEVCONTAINER=1 bash "${REPO_ROOT}/scripts/run_after_20_agent_tools.tmpl"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Container environment detected"* ]]
}

@test "run_after_20_agent_tools verify_sha256 rejects bad checksums" {
  local rendered="${BATS_TEST_TMPDIR}/run_after_20.sh"
  gap_render_script "${REPO_ROOT}/scripts/run_after_20_agent_tools.tmpl" "$rendered"
  local helper="${BATS_TEST_TMPDIR}/verify_only.sh"
  {
    echo 'set -euo pipefail'
    sed -n '/^verify_sha256()/,/^}/p' "$rendered"
    cat <<'EOF'
tmp="$(mktemp)"
printf "not-the-archive\n" >"$tmp"
verify_sha256 "0000000000000000000000000000000000000000000000000000000000000000" "$tmp"
EOF
  } >"$helper"
  run bash "$helper"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Checksum mismatch"* ]]
}

@test "run_after_20_agent_tools includes pinned runtime versions in source" {
  grep -Fq 'readonly beads_version="1.1.2"' "${REPO_ROOT}/scripts/run_after_20_agent_tools.tmpl"
  grep -Fq 'readonly omp_version="17.2.10"' "${REPO_ROOT}/scripts/run_after_20_agent_tools.tmpl"
  grep -Fq 'readonly pi_version="0.84.1"' "${REPO_ROOT}/scripts/run_after_20_agent_tools.tmpl"
}
