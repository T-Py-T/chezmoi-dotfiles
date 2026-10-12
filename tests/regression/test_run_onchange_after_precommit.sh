#!/usr/bin/env bash
# Regression: Intel macOS Homebrew lives at /usr/local/bin/brew when PATH is minimal.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="${repo_root}/scripts/run_onchange_after_precommit.tmpl"

if [ ! -f "$script" ]; then
  echo "missing $script" >&2
  exit 1
fi

if ! grep -Fq '/usr/local/bin/brew' "$script"; then
  echo "run_onchange_after_precommit.tmpl must recognize /usr/local/bin/brew" >&2
  exit 1
fi

if ! grep -Fq 'eval "$(/usr/local/bin/brew shellenv)"' "$script"; then
  echo "run_onchange_after_precommit.tmpl must eval Intel macOS brew shellenv" >&2
  exit 1
fi

echo "ok run_onchange_after_precommit regression"
