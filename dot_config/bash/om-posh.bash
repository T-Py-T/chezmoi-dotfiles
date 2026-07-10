# dot_config/bash/om-posh.bash
# Initialize the starship prompt for bash. Mirrors dot_config/zsh/om-posh.zsh.
# Sourced by ~/.bashrc via the ~/.config/bash/*.bash glob; Homebrew is handled
# separately by 00-homebrew.bash, mise is activated in the ~/.bashrc entry point.

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
