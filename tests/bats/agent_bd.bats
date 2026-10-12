#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  # shellcheck disable=SC2034
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  BD_BIN="${BATS_TEST_TMPDIR}/bd"
  cat >"$BD_BIN" <<'EOF'
#!/usr/bin/env bash
printf 'actor=%s\n' "${BD_ACTOR:-}"
printf 'metrics=%s\n' "${BD_DISABLE_METRICS:-}"
printf 'args=%s\n' "$*"
exit 0
EOF
  chmod +x "$BD_BIN"
  export PATH="${BATS_TEST_TMPDIR}:${PATH}"
  export USER="tester"
}

agent_bd() {
  bash "${REPO_ROOT}/dot_local/bin/executable_agent-bd" "$@"
}

@test "agent-bd rejects missing delimiter" {
  run agent_bd omp worker-01 ready
  [ "$status" -eq 2 ]
}

@test "agent-bd sanitizes harness and worker id" {
  run agent_bd 'omp beta' 'worker 01' -- ready
  [ "$status" -eq 0 ]
  [[ "$output" == *"actor=tester@"*":omp-beta:worker-01"* ]]
  [[ "$output" == *"metrics=1"* ]]
  [[ "$output" == *"args="*" ready"* ]]
}

@test "agent-bd exits 127 when bd is missing" {
  run -127 env PATH="/usr/bin:/bin" bash "${REPO_ROOT}/dot_local/bin/executable_agent-bd" omp w1 -- ready
}
