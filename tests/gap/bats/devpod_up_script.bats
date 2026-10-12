#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/support.bash"

setup() {
  REPO_ROOT="$GAP_REPO_ROOT"
}

@test "devpod-up.sh is valid bash" {
  run bash -n "${REPO_ROOT}/scripts/devpod-up.sh"
  [ "$status" -eq 0 ]
}

@test "devpod-up performs delete and up with workspace id" {
  local stub_dir="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "$stub_dir"
  cat >"$stub_dir/devpod" <<'EOF'
#!/usr/bin/env bash
echo "devpod $*"
EOF
  chmod +x "$stub_dir/devpod"
  run env PATH="$stub_dir:/usr/bin:/bin" bash "${REPO_ROOT}/scripts/devpod-up.sh" my-ws
  [ "$status" -eq 0 ]
  [[ "$output" == *"devpod delete my-ws --force"* ]]
  [[ "$output" == *"devpod up . --reset --id my-ws"* ]]
  [[ "$output" == *"devpod ssh my-ws"* ]]
}
