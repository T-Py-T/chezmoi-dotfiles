# Homebrew installs fzf under different prefixes (Apple Silicon, Intel, Linuxbrew).
for fzf_prefix in \
  /opt/homebrew/opt/fzf \
  /usr/local/opt/fzf \
  /home/linuxbrew/.linuxbrew/opt/fzf; do
  if [[ -d "$fzf_prefix" ]]; then
    if [[ ! "$PATH" == *"${fzf_prefix}/bin"* ]]; then
      export PATH="${PATH:+${PATH}:}${fzf_prefix}/bin"
    fi

    # Auto-completion and key bindings (interactive shells only).
    if [[ $- == *i* ]]; then
      source "${fzf_prefix}/shell/completion.zsh" 2> /dev/null
      source "${fzf_prefix}/shell/key-bindings.zsh" 2> /dev/null
    fi
    break
  fi
done
