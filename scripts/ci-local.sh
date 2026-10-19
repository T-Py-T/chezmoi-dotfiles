#!/usr/bin/env bash
# scripts/ci-local.sh
# Runs the same validation steps as hosted CI (pre-commit, mise, starship).
# Optional NeoVim health check when --nvim-health is passed (requires nvim on PATH).
#
# Outside GitHub Actions this script never installs anything or writes to $HOME:
# mise and starship must already be on PATH, and the nvim health check runs
# against a copy of dot_config/nvim inside a throwaway HOME.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RUN_NVIM_HEALTH=0
ONLY_NVIM_HEALTH=0
for arg in "$@"; do
  case "$arg" in
    --nvim-health) RUN_NVIM_HEALTH=1 ;;
    --only-nvim-health)
      ONLY_NVIM_HEALTH=1
      RUN_NVIM_HEALTH=1
      ;;
    -h | --help)
      echo "Usage: $0 [--nvim-health | --only-nvim-health]"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

in_github_actions() {
  [[ -n "${GITHUB_ACTIONS:-}" ]]
}

require_local_tool() {
  echo "$1 is not on PATH. Install it first (for example: $2), then re-run." >&2
  echo "ci-local only downloads tools when running in GitHub Actions." >&2
  exit 1
}

install_mise() {
  if command -v mise >/dev/null 2>&1; then
    return 0
  fi
  if ! in_github_actions; then
    require_local_tool mise "brew install mise"
  fi
  case "$(uname -m)" in
    x86_64)
      mise_arch="x64"
      mise_sha256="04260a49d2cb7f46c91d3f90547f8486ba6c6c9e545b98e69b685cdcf0db8576"
      ;;
    aarch64 | arm64)
      mise_arch="arm64"
      mise_sha256="7892401c3a3b8166e8be3a3bbd564f48b36946e580e031f2df94a4935edfd907"
      ;;
    *)
      echo "Unsupported architecture for mise: $(uname -m)" >&2
      exit 1
      ;;
  esac
  local tmp
  tmp="$(mktemp)"
  curl -fsSL \
    "https://github.com/jdx/mise/releases/download/v2026.9.6/mise-v2026.9.6-linux-${mise_arch}" \
    -o "$tmp"
  echo "${mise_sha256}  $tmp" | sha256sum --check --strict
  mkdir -p "${HOME}/.local/bin"
  install -m 0755 "$tmp" "${HOME}/.local/bin/mise"
  rm -f "$tmp"
  export PATH="${HOME}/.local/bin:${PATH}"
}

install_starship() {
  if command -v starship >/dev/null 2>&1; then
    return 0
  fi
  if ! in_github_actions; then
    require_local_tool starship "brew install starship"
  fi
  case "$(uname -m)" in
    x86_64)
      starship_target="x86_64-unknown-linux-musl"
      starship_sha256="b7c232b0e8249d8e55a40beb79c5c43a7d370f3f9408bd215deb0170daeaadf3"
      ;;
    aarch64 | arm64)
      starship_target="aarch64-unknown-linux-musl"
      starship_sha256="dc30189378d2f2e287384e8a692d3f95ad1df64cf0e8c36aa9201516028aed6b"
      ;;
    *)
      echo "Unsupported architecture for starship: $(uname -m)" >&2
      exit 1
      ;;
  esac
  local tmp tar
  tmp="$(mktemp -d)"
  tar="${tmp}/starship.tar.gz"
  curl -fsSL \
    "https://github.com/starship/starship/releases/download/v1.26.0/starship-${starship_target}.tar.gz" \
    -o "$tar"
  echo "${starship_sha256}  $tar" | sha256sum --check --strict
  tar -xzf "$tar" -C "$tmp" starship
  if [[ -w /usr/local/bin ]]; then
    install -m 0755 "${tmp}/starship" /usr/local/bin/starship
  else
    sudo install -m 0755 "${tmp}/starship" /usr/local/bin/starship
  fi
  rm -rf "$tmp"
}

run_pre_commit() {
  if ! command -v pre-commit >/dev/null 2>&1; then
    echo "pre-commit is not installed; install with: pip install pre-commit" >&2
    exit 1
  fi
  pre-commit run --all-files --show-diff-on-failure
}

run_mise_validate() {
  install_mise
  mise config ls
}

run_starship_validate() {
  install_starship
  STARSHIP_CONFIG="${REPO_ROOT}/dot_config/starship.toml" starship explain
}

bootstrap_nvim_plugins() {
  if ! command -v nvim >/dev/null 2>&1; then
    echo "nvim is not on PATH (required for --nvim-health)" >&2
    exit 1
  fi
  export TERM="${TERM:-xterm-256color}"
  local timeout_cmd=()
  if command -v timeout >/dev/null 2>&1; then
    timeout_cmd=(timeout 300)
  elif command -v gtimeout >/dev/null 2>&1; then
    timeout_cmd=(gtimeout 300)
  fi
  ${timeout_cmd[@]+"${timeout_cmd[@]}"} nvim --headless -c "qa" 2>/dev/null || true
}

use_temporary_nvim_home() {
  # Hosted CI copies the config into the runner's HOME (see nvim-health.yml).
  # Locally, never touch the real ~/.config/nvim or ~/.local/share/nvim.
  NVIM_TMP_HOME="$(mktemp -d)"
  trap 'rm -rf "${NVIM_TMP_HOME}"' EXIT
  export HOME="${NVIM_TMP_HOME}"
  unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
  mkdir -p "${HOME}/.config"
  cp -R "${REPO_ROOT}/dot_config/nvim" "${HOME}/.config/nvim"
  echo "nvim health: using temporary HOME ${HOME}"
}

run_nvim_health() {
  if ! in_github_actions; then
    use_temporary_nvim_home
  fi
  bootstrap_nvim_plugins
  chmod +x "${REPO_ROOT}/scripts/check-nvim-health.sh"
  bash "${REPO_ROOT}/scripts/check-nvim-health.sh"
}

if [[ "$ONLY_NVIM_HEALTH" -eq 0 ]]; then
  echo "==> pre-commit"
  run_pre_commit

  echo "==> mise.toml"
  run_mise_validate

  echo "==> starship.toml"
  run_starship_validate
fi

if [[ "$RUN_NVIM_HEALTH" -eq 1 ]]; then
  echo "==> nvim health"
  run_nvim_health
fi

echo "ci-local: all checks passed."
