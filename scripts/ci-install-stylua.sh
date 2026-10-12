#!/usr/bin/env bash
# scripts/ci-install-stylua.sh
# Installs a checksum-pinned StyLua release for CI and local pre-commit (stylua-system hook).
# Does not modify shell profiles; installs to /usr/local/bin when run with sufficient privileges.

set -euo pipefail

readonly stylua_version="2.6.0"
readonly install_dir="${STYLUA_INSTALL_DIR:-/usr/local/bin}"

case "$(uname -m)" in
  x86_64)
    stylua_asset="stylua-linux-x86_64.zip"
    stylua_sha256="a485f72bbfa22e4642e77a84b5edc2611a5cab7477b34e2e709dd8f78e919895"
    ;;
  aarch64 | arm64)
    stylua_asset="stylua-linux-aarch64.zip"
    stylua_sha256="8e67539e5fdf7a81cd03cf592b0df18d3bb96ee17a5ea5d9bf67b86387b903b0"
    ;;
  *)
    echo "Unsupported architecture for StyLua install: $(uname -m)" >&2
    exit 1
    ;;
esac

archive="${TMPDIR:-/tmp}/stylua-${stylua_version}.zip"
curl -fsSL \
  "https://github.com/JohnnyMorganz/StyLua/releases/download/v${stylua_version}/${stylua_asset}" \
  -o "$archive"
echo "${stylua_sha256}  ${archive}" | sha256sum --check --strict
unzip -qo "$archive" stylua -d "${TMPDIR:-/tmp}"
install -m 0755 "${TMPDIR:-/tmp}/stylua" "${install_dir}/stylua"
rm -f "$archive" "${TMPDIR:-/tmp}/stylua"

stylua --version
