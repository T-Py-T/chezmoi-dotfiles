#!/usr/bin/env bash
# Regression: incomplete Pi install directories are replaced instead of aborting.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

readonly beads_version="1.1.2"
readonly omp_version="17.2.10"
readonly pi_version="0.84.1"
readonly pi_sha256="5634d7ebd18274b63af3371e942f342d74bea012389575c1d1ff15ce6ca80c2f"

tools_root="$tmpdir/agent-tools"
bin_dir="$tmpdir/bin"
mkdir -p "$bin_dir" "$tmpdir/mock-bin"

build_pi_archive() {
  local out="$1"
  mkdir -p "$tmpdir/pi-inner/pi"
  cat >"$tmpdir/pi-inner/pi/pi" <<'EOF'
#!/bin/sh
echo "pi version 0.84.1"
EOF
  chmod +x "$tmpdir/pi-inner/pi/pi"
  tar -C "$tmpdir/pi-inner" -czf "$out" pi
}

cat >"$tmpdir/mock-bin/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
url=""
out=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --output)
      out="$2"
      shift 2
      ;;
    *)
      url="$1"
      shift
      ;;
  esac
done
if [[ "$url" != *"/pi/releases/download/"* ]]; then
  echo "unexpected curl URL: $url" >&2
  exit 1
fi
# Rebuild archive at runtime; checksum mock returns the pinned digest for Pi.
"$(dirname "$0")/build-pi-archive.sh" "$out"
EOF
chmod +x "$tmpdir/mock-bin/curl"

cat >"$tmpdir/mock-bin/build-pi-archive.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
out="$1"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmpdir="$(dirname "$root")"
mkdir -p "$tmpdir/pi-inner/pi"
cat >"$tmpdir/pi-inner/pi/pi" <<'INNER'
#!/bin/sh
echo "pi version 0.84.1"
INNER
chmod +x "$tmpdir/pi-inner/pi/pi"
tar -C "$tmpdir/pi-inner" -czf "$out" pi
EOF
chmod +x "$tmpdir/mock-bin/build-pi-archive.sh"

cat >"$tmpdir/mock-bin/sha256sum" <<EOF
#!/usr/bin/env bash
file="\${@: -1}"
if [[ "\$file" == *pi.tar.gz ]]; then
  echo "${pi_sha256}  \$file"
else
  echo "checksum mock missing digest for \$file" >&2
  exit 1
fi
EOF
chmod +x "$tmpdir/mock-bin/sha256sum"

mkdir -p "$tools_root/beads/$beads_version" "$tools_root/omp/$omp_version"
cat >"$tools_root/beads/$beads_version/bd" <<EOF
#!/bin/sh
case "\$1" in
  --version) echo "bd version ${beads_version}" ;;
  metrics) ;;
esac
EOF
chmod +x "$tools_root/beads/$beads_version/bd"

cat >"$tools_root/omp/$omp_version/omp" <<EOF
#!/bin/sh
echo "omp ${omp_version}"
EOF
chmod +x "$tools_root/omp/$omp_version/omp"

mkdir -p "$tools_root/pi/$pi_version"
printf 'partial download\n' >"$tools_root/pi/$pi_version/.partial"

rendered="$tmpdir/run_after_20_agent_tools.sh"
sed "s|{{ .chezmoi.sourceDir }}|$ROOT|g" "$ROOT/scripts/run_after_20_agent_tools.tmpl" >"$rendered"
chmod +x "$rendered"

if ! env \
  PATH="$tmpdir/mock-bin:$bin_dir:$PATH" \
  AGENT_TOOLS_ROOT="$tools_root" \
  AGENT_BIN_DIR="$bin_dir" \
  SKIP_HERMES_AGENT=1 \
  bash "$rendered" >/dev/null; then
  echo "FAIL: agent runtime script should recover incomplete Pi install" >&2
  exit 1
fi

if [ ! -x "$tools_root/pi/$pi_version/pi" ]; then
  echo "FAIL: Pi binary was not installed after recovery" >&2
  exit 1
fi

if [ ! -L "$bin_dir/pi" ] || [ "$(readlink "$bin_dir/pi")" != "$tools_root/pi/$pi_version/pi" ]; then
  echo "FAIL: Pi symlink was not linked into AGENT_BIN_DIR" >&2
  exit 1
fi

echo "ok   incomplete Pi directory is replaced and linked"
