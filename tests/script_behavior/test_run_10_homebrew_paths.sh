#!/usr/bin/env bash
# Non-container branch selection in scripts/run_10_homebrew (WSL vs Linux).

set -euo pipefail

# shellcheck source=lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/brew" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  update) exit 0 ;;
  bundle)
    if [ "$2" = "install" ] && [ "$3" = "--file" ]; then
      echo "bundle-install:${4}"
      exit 0
    fi
    if [ "$2" = "install" ] && [ "$3" = "--global" ]; then
      echo "bundle-install:--global"
      exit 0
    fi
    if [ "$2" = "cleanup" ] && [ "$3" = "--file" ]; then
      echo "bundle-cleanup:${4}"
      exit 0
    fi
    if [ "$2" = "cleanup" ] && [ "$3" = "--global" ]; then
      echo "bundle-cleanup:--global"
      exit 0
    fi
    ;;
  upgrade) exit 0 ;;
esac
echo "unexpected brew call: $*" >&2
exit 1
EOF
chmod +x "$tmpdir/brew"

run_homebrew() {
  local proc_version="$1"
  mkdir -p "$tmpdir/proc"
  printf '%s\n' "$proc_version" >"$tmpdir/proc/version"
  env -u DEVCONTAINER \
    CHEZMOI_SOURCE_DIR="$repo_root" \
    PATH="$tmpdir:$PATH" \
    WSL_DISTRO_NAME="${WSL_DISTRO_NAME:-}" \
    bash "$repo_root/scripts/run_10_homebrew" 2>&1
}

output="$(run_homebrew "Linux version 6.1.0-generic")"
assert_contains "$output" "bundle-install:${repo_root}/brew/linux/dot_Brewfile.tmpl" "plain linux"
ok "run_10_homebrew picks linux Brewfile on non-WSL"

output="$(
  WSL_DISTRO_NAME=Ubuntu run_homebrew "Linux version 6.1.0-microsoft-standard-WSL2"
)"
assert_contains "$output" "bundle-install:${repo_root}/brew/linux/dot_Brewfile-wsl.tmpl" "wsl"
ok "run_10_homebrew picks WSL Brewfile when WSL markers are present"

empty_source="$(mktemp -d)"
output="$(
  assert_exit 0 env -u DEVCONTAINER CHEZMOI_SOURCE_DIR="$empty_source" PATH="$tmpdir:$PATH" \
    bash "$repo_root/scripts/run_10_homebrew"
)"
assert_contains "$output" "bundle-install:--global" "global bundle fallback"
ok "run_10_homebrew falls back to global bundle without OS Brewfile"

output="$(
  assert_exit 1 env -u DEVCONTAINER CHEZMOI_SOURCE_DIR="$repo_root" PATH="/usr/bin:/bin" \
    bash "$repo_root/scripts/run_10_homebrew"
)"
assert_contains "$output" "Homebrew is not installed" "missing brew"
ok "run_10_homebrew errors when brew is unavailable"
