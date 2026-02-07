if command -v oh-my-posh &> /dev/null && [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config  $HOME/.config/ohmyposh/tokyns.toml 2> /dev/null)" || true
fi
