#!/bin/bash
eval "$(mise activate bash)"

echo "=== NeoVim Version ==="
nvim --version | head -1

echo -e "\n=== Python Support ==="
python3 --version 2>&1

echo -e "\n=== Node.js Support ==="
which node >/dev/null 2>&1 && node --version || echo "NOT INSTALLED"

echo -e "\n=== Ruby Support ==="
which ruby >/dev/null 2>&1 && ruby --version || echo "NOT INSTALLED"

echo -e "\n=== Perl Support ==="
which perl >/dev/null 2>&1 && perl --version 2>&1 | head -2 || echo "NOT INSTALLED"

echo -e "\n=== External Tool Dependencies ==="
echo "ripgrep: $(rg --version | head -1)"
echo "fzf: $(fzf --version)"
echo "fd: $(fd --version)"

echo -e "\n=== Clipboard Support ==="
which xclip >/dev/null 2>&1 && echo "xclip: OK" || echo "xclip: NOT INSTALLED"
which xsel >/dev/null 2>&1 && echo "xsel: OK" || echo "xsel: NOT INSTALLED"

echo -e "\n=== Additional Tools ==="
which git >/dev/null 2>&1 && echo "git: OK ($(git --version))" || echo "git: NOT INSTALLED"
which make >/dev/null 2>&1 && echo "make: OK" || echo "make: NOT INSTALLED"
which gcc >/dev/null 2>&1 && echo "gcc: OK" || echo "gcc: NOT INSTALLED"

