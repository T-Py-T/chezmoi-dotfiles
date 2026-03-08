# dot_config/zsh/00-homebrew.zsh
# Activates Homebrew for zsh. Covers Linux (linuxbrew) and macOS paths.
# Does not install Homebrew - that is handled by run_once_before_setup.tmpl.

if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
