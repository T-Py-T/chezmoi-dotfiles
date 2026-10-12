#!/usr/bin/env bash
# check-nvim-health.sh error counting via a mocked nvim binary.

set -euo pipefail
# shellcheck source=tests/template_script_specs/lib/common.sh
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

script="$REPO_ROOT/scripts/check-nvim-health.sh"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

install_fake_nvim() {
  cat >"$tmpdir/nvim" <<'EOF'
#!/usr/bin/env bash
if [ "${NVIM_HEALTH_MODE:-write}" = "skip" ]; then
  exit 0
fi
for arg in "$@"; do
  case "$arg" in
    "silent! w!"*)
      outfile="${arg#silent! w! }"
      printf '%s' "${NVIM_HEALTH_FIXTURE:-}" >"$outfile"
      ;;
  esac
done
exit 0
EOF
  chmod +x "$tmpdir/nvim"
}

install_fake_nvim
output="$(assert_exit_code 1 env NVIM_HEALTH_MODE=skip PATH="$tmpdir:/usr/bin:/bin" bash "${script}")"
assert_contains "$output" "Health output file was not created" "missing health file fails"

export NVIM_HEALTH_FIXTURE=$'plugin OK\nlsp ERROR something broke\nlint WARNING minor\n'
output="$(assert_exit_code 1 env NVIM_HEALTH_MODE=write PATH="$tmpdir:/usr/bin:/bin" bash "${script}")"
assert_contains "$output" "ERRORS:   1" "counts errors"
assert_contains "$output" "FAIL: 1 ERROR" "fails on errors"

export NVIM_HEALTH_FIXTURE=$'everything OK\nlint WARNING only\n'
output="$(assert_exit_code 0 env NVIM_HEALTH_MODE=write PATH="$tmpdir:/usr/bin:/bin" bash "${script}")"
assert_contains "$output" "PASS: nvim health check" "passes without errors"

finish_suite
