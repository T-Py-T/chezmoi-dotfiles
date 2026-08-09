# User-owned portable tools (chezmoi, agent runtimes, and local helpers) win over
# package-manager copies.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
