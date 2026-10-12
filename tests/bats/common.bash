# Shared helpers for bats tests.

repo_root() {
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
  cd "${here}/../.." && pwd
}

health_error_count() {
  local file="$1"
  LC_ALL=C strings "$file" | awk '/ERROR/{c++} END{print c+0}'
}
