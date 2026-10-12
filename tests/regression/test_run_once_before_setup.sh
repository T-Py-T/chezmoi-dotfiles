#!/usr/bin/env bash
# Regression: Intel macOS Homebrew lives at /usr/local/bin/brew when PATH is minimal.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="${repo_root}/scripts/run_once_before_setup.tmpl"

if [ ! -f "$script" ]; then
  echo "missing $script" >&2
  exit 1
fi

if ! grep -Fq '/usr/local/bin/brew' "$script"; then
  echo "run_once_before_setup.tmpl must recognize /usr/local/bin/brew" >&2
  exit 1
fi

# Install guard and shellenv activation must both mention the Intel macOS path.
count="$(grep -Fc '/usr/local/bin/brew' "$script" || true)"
if [ "$count" -lt 2 ]; then
  echo "expected /usr/local/bin/brew in install guard and shellenv activation (found $count)" >&2
  exit 1
fi

if ! grep -Fq 'eval "$(/usr/local/bin/brew shellenv)"' "$script"; then
  echo "run_once_before_setup.tmpl must eval Intel macOS brew shellenv" >&2
  exit 1
fi

echo "ok run_once_before_setup regression"
