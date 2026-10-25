#!/usr/bin/env bash
# Regression: shell_aliases must not override the eza ls alias from eza-ls.zsh.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT

if ! command -v zsh >/dev/null 2>&1; then
  echo "SKIP: zsh is not installed"
  exit 0
fi

mkdir -p "$tmp_home/.config/zsh" "$tmp_home/bin"
install -m 0755 "$repo_root/dot_zshrc" "$tmp_home/.zshrc"
cp "$repo_root/dot_config/shell_aliases" "$tmp_home/.config/shell_aliases"
cp "$repo_root/dot_config/zsh/eza-ls.zsh" "$tmp_home/.config/zsh/eza-ls.zsh"

# Stub eza so eza-ls.zsh defines the alias without requiring a real binary package.
cat >"$tmp_home/bin/eza" <<'EOF'
#!/usr/bin/env bash
echo eza-stub
EOF
chmod +x "$tmp_home/bin/eza"

ls_alias="$(
  HOME="$tmp_home" PATH="$tmp_home/bin:$PATH" zsh -df -c '
    source "$HOME/.zshrc"
    alias ls
  '
)"

if [[ "$ls_alias" != *eza* ]]; then
  echo "FAIL: expected ls alias to use eza after sourcing ~/.zshrc" >&2
  echo "Got: $ls_alias" >&2
  exit 1
fi

echo "PASS: eza ls alias survives shell_aliases load order"
