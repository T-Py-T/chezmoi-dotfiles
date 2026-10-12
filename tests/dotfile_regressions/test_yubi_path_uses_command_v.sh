#!/usr/bin/env bash
# Regression: YubiKey Manager PATH hook must not depend on external `which`.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT

if ! command -v zsh >/dev/null 2>&1; then
  echo "SKIP: zsh is not installed"
  exit 0
fi

mkdir -p \
  "$tmp_home/bin" \
  "$tmp_home/Applications/YubiKey Manager.app/Contents/MacOS"

cat >"$tmp_home/bin/art" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$tmp_home/bin/art"

yubi_bin="$tmp_home/Applications/YubiKey Manager.app/Contents/MacOS"
cat >"$yubi_bin/ykman" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$yubi_bin/ykman"

path_after="$(
  HOME="$tmp_home" PATH="$tmp_home/bin:$PATH" zsh -df -c "
    source \"$repo_root/dot_config/zsh/00-yubi.zsh\"
    print -r -- \$path
  "
)"

if [[ "$path_after" != *"YubiKey Manager.app/Contents/MacOS"* ]]; then
  echo "FAIL: expected YubiKey Manager bin directory on zsh path" >&2
  echo "path=$path_after" >&2
  exit 1
fi

# A broken `which` in PATH must not prevent the hook (command -v is used instead).
cat >"$tmp_home/bin/which" <<'EOF'
#!/usr/bin/env bash
echo "which must not be consulted for art" >&2
exit 1
EOF
chmod +x "$tmp_home/bin/which"

path_without_which="$(
  HOME="$tmp_home" PATH="$tmp_home/bin:$PATH" zsh -df -c "
    source \"$repo_root/dot_config/zsh/00-yubi.zsh\"
    print -r -- \$path
  "
)"

if [[ "$path_without_which" != *"YubiKey Manager.app/Contents/MacOS"* ]]; then
  echo "FAIL: YubiKey path hook must use command -v, not which" >&2
  echo "path=$path_without_which" >&2
  exit 1
fi

echo "PASS: YubiKey PATH hook works without external which"
