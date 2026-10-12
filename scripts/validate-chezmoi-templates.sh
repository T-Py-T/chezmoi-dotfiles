#!/usr/bin/env bash
# scripts/validate-chezmoi-templates.sh
# Renders chezmoi templates and validates bootstrap scripts after rendering.
# Does not apply dotfiles or run Homebrew/agent installers.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
chezmoi_bin="${CHEZMOI_BIN:-chezmoi}"
shellcheck_bin="${SHELLCHECK_BIN:-shellcheck}"

if ! command -v "$chezmoi_bin" >/dev/null 2>&1; then
  echo "chezmoi not found (set CHEZMOI_BIN or install via scripts/ci-install-chezmoi.sh)" >&2
  exit 1
fi

if ! command -v "$shellcheck_bin" >/dev/null 2>&1; then
  echo "shellcheck not found (set SHELLCHECK_BIN or install shellcheck)" >&2
  exit 1
fi

render_template() {
  "$chezmoi_bin" --source "$repo_root" execute-template --init -f "$1"
}

tmpdir="$(mktemp -d)"
scratch="$(mktemp -d)"
trap 'rm -rf "$tmpdir" "$scratch"' EXIT

failures=0

while IFS= read -r -d '' tmpl; do
  rel="${tmpl#"$repo_root"/}"
  printf 'Rendering %s\n' "$rel"
  if ! render_template "$rel" > "$tmpdir/rendered"; then
    printf 'FAIL: could not render %s\n' "$rel" >&2
    failures=$((failures + 1))
    continue
  fi

  case "$rel" in
    scripts/*.tmpl)
      printf '  bash -n + shellcheck (rendered)\n'
      if ! bash -n "$tmpdir/rendered"; then
        printf 'FAIL: bash -n on rendered %s\n' "$rel" >&2
        failures=$((failures + 1))
        continue
      fi
      if ! "$shellcheck_bin" -S warning --shell=bash "$tmpdir/rendered"; then
        printf 'FAIL: shellcheck on rendered %s\n' "$rel" >&2
        failures=$((failures + 1))
      fi
      ;;
    brew/*)
      if grep -qE '\{\{|\}\}' "$tmpdir/rendered"; then
        printf 'FAIL: unresolved template markers in %s\n' "$rel" >&2
        failures=$((failures + 1))
      fi
      ;;
  esac
done < <(find "$repo_root/scripts" "$repo_root/brew" -name '*.tmpl' -print0 | sort -z)

printf 'chezmoi apply --dry-run (excluding bootstrap scripts)\n'
if ! "$chezmoi_bin" --source "$repo_root" \
  --destination "$scratch/home" \
  --config "$scratch/chezmoi.toml" \
  --persistent-state "$scratch/state.boltdb" \
  --cache "$scratch/cache" \
  apply --dry-run --exclude=scripts >/dev/null; then
  printf 'FAIL: chezmoi apply --dry-run\n' >&2
  failures=$((failures + 1))
fi

if [ "$failures" -gt 0 ]; then
  printf '%d template validation failure(s)\n' "$failures" >&2
  exit 1
fi

printf 'All chezmoi template checks passed.\n'
