#!/usr/bin/env bash
# Container branch of scripts/run_10_homebrew without a real brew install.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/brew" <<'EOF'
#!/usr/bin/env bash
if [ "$1" = "bundle" ] && [ "$2" = "--file" ]; then
  echo "bundle:$3"
  exit 0
fi
exit 1
EOF
chmod +x "$tmpdir/brew"

output="$(
  env DEVCONTAINER=1 \
    CHEZMOI_SOURCE_DIR="$ROOT" \
    PATH="$tmpdir:$PATH" \
    bash "$ROOT/scripts/run_10_homebrew"
)"

if ! printf '%s' "$output" | grep -Fq "devcontainer Brewfile"; then
  echo "expected devcontainer Brewfile message" >&2
  exit 1
fi

if ! printf '%s' "$output" | grep -Fq "bundle:${ROOT}/brew/devcontainer/dot_Brewfile.tmpl"; then
  echo "expected bundle against devcontainer Brewfile" >&2
  printf '%s\n' "$output"
  exit 1
fi

echo "ok   run_10_homebrew container path"
