#!/usr/bin/env bash
# Regression: Neovim 0.11+ renamed vim.highlight to vim.hl; 0.12 configs must not
# call vim.highlight.on_yank() or highlight-on-yank fails at runtime.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INIT_LUA="${ROOT}/dot_config/nvim/init.lua"
failures=0

if grep -Fq 'vim.highlight.on_yank' "$INIT_LUA"; then
  echo "FAIL: init.lua still calls removed vim.highlight.on_yank API" >&2
  failures=$((failures + 1))
fi

if ! grep -Fq 'vim.hl.on_yank' "$INIT_LUA"; then
  echo "FAIL: init.lua must call vim.hl.on_yank for Neovim 0.12+" >&2
  failures=$((failures + 1))
fi

run_nvim_runtime_check() {
  local nvim_bin="$1"
  if ! "$nvim_bin" --headless \
    +"lua assert(vim.hl and vim.hl.on_yank, 'vim.hl.on_yank missing')" \
    +"lua assert(vim.highlight == nil, 'vim.highlight must not exist on 0.12+')" \
    +qa! 2>/dev/null; then
    echo "FAIL: nvim runtime API check failed ($nvim_bin)" >&2
    failures=$((failures + 1))
  else
    echo "ok   nvim runtime exposes vim.hl.on_yank (no vim.highlight)"
  fi
}

ensure_nvim() {
  if command -v nvim >/dev/null 2>&1; then
    command -v nvim
    return 0
  fi

  echo "note: nvim not on PATH; downloading Neovim 0.12.5 for runtime check" >&2
  nvim_cache="${ROOT}/.cache/test-nvim"
  mkdir -p "$nvim_cache"
  nvim_bin="${nvim_cache}/nvim"
  if [ -x "$nvim_bin" ]; then
    printf '%s\n' "$nvim_bin"
    return 0
  fi

  case "$(uname -m)" in
    x86_64)
      archive="nvim-linux-x86_64"
      checksum="bce0f56eda1f1b1db6eee8f4133d7a38813ea07933837dd1777411ca384c6875"
      ;;
    aarch64|arm64)
      archive="nvim-linux-arm64"
      checksum="1aa5ca085249580ae0f91eb14f27ec0919773ff2d99a163d03f3d6c21ac29725"
      ;;
    *)
      echo "SKIP: unsupported architecture for nvim download: $(uname -m)" >&2
      return 1
      ;;
  esac

  tarball="${nvim_cache}/${archive}.tar.gz"
  curl -fsSL \
    "https://github.com/neovim/neovim/releases/download/v0.12.5/${archive}.tar.gz" \
    -o "$tarball"
  echo "${checksum}  ${tarball}" | sha256sum --check --strict
  tar -xzf "$tarball" -C "$nvim_cache"
  install -m 0755 "${nvim_cache}/${archive}/bin/nvim" "$nvim_bin"
  printf '%s\n' "$nvim_bin"
}

if nvim_bin="$(ensure_nvim)"; then
  run_nvim_runtime_check "$nvim_bin"
fi

if [ "$failures" -ne 0 ]; then
  echo "$failures test(s) failed" >&2
  exit 1
fi

echo "All nvim yank highlight API tests passed."
