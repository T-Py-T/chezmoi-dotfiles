#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/support.bash"

setup() {
  REPO_ROOT="$GAP_REPO_ROOT"
}

@test "check-nvim-health fails when nvim does not write output" {
  local stub_dir="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "$stub_dir"
  cat >"$stub_dir/nvim" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$stub_dir/nvim"
  run env PATH="$stub_dir:/usr/bin:/bin" bash "${REPO_ROOT}/scripts/check-nvim-health.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Health output file was not created"* ]]
}

@test "check-nvim-health passes with clean fixture output" {
  local stub_dir="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "$stub_dir"
  cat >"$stub_dir/nvim" <<'EOF'
#!/usr/bin/env bash
out=""
prev=""
for arg in "$@"; do
  if [ "$prev" = "-c" ]; then
    case "$arg" in
      *w!*)
        out="${arg##*w! }"
        ;;
    esac
  fi
  prev="$arg"
done
printf 'Neovim: OK\n' >"$out"
exit 0
EOF
  chmod +x "$stub_dir/nvim"
  run env PATH="$stub_dir:/usr/bin:/bin" bash "${REPO_ROOT}/scripts/check-nvim-health.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"PASS"* ]]
}

@test "check-nvim-health fails when fixture contains ERROR lines" {
  local stub_dir="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "$stub_dir"
  cat >"$stub_dir/nvim" <<'EOF'
#!/usr/bin/env bash
out=""
prev=""
for arg in "$@"; do
  if [ "$prev" = "-c" ]; then
    case "$arg" in
      *w!*)
        out="${arg##*w! }"
        ;;
    esac
  fi
  prev="$arg"
done
printf 'Plugin: ERROR something broke\n' >"$out"
exit 0
EOF
  chmod +x "$stub_dir/nvim"
  run env PATH="$stub_dir:/usr/bin:/bin" bash "${REPO_ROOT}/scripts/check-nvim-health.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL"* ]]
  [[ "$output" == *"ERROR something broke"* ]]
}
