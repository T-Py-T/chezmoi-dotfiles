#!/usr/bin/env bash
# scripts/ci-install-chezmoi.sh
# Installs a checksum-pinned chezmoi release for CI template validation.
# Does not modify shell profiles; installs to /usr/local/bin when run with sufficient privileges.

set -euo pipefail

readonly chezmoi_version="2.73.1"
readonly install_dir="${CHEZMOI_INSTALL_DIR:-/usr/local/bin}"

case "$(uname -m)" in
  x86_64)
    chezmoi_asset="chezmoi_${chezmoi_version}_linux_amd64.tar.gz"
    chezmoi_sha256="a3f958acb7d0e5d53fa43c2eec9bc8ae3b4fba8bcbfdce29a8881ca3ffc20a53"
    ;;
  aarch64 | arm64)
    chezmoi_asset="chezmoi_${chezmoi_version}_linux_arm64.tar.gz"
    chezmoi_sha256="e60275b27f505ae2086bfb87b144eacf7377a89803120f6bd933d1852a93b0c6"
    ;;
  *)
    echo "Unsupported architecture for chezmoi install: $(uname -m)" >&2
    exit 1
    ;;
esac

archive="${TMPDIR:-/tmp}/chezmoi-${chezmoi_version}.tar.gz"
curl -fsSL \
  "https://github.com/twpayne/chezmoi/releases/download/v${chezmoi_version}/${chezmoi_asset}" \
  -o "$archive"
echo "${chezmoi_sha256}  ${archive}" | sha256sum --check --strict
tar -xzf "$archive" -C "${TMPDIR:-/tmp}" chezmoi
install -m 0755 "${TMPDIR:-/tmp}/chezmoi" "${install_dir}/chezmoi"
rm -f "$archive" "${TMPDIR:-/tmp}/chezmoi"

chezmoi --version
