# User-owned portable tools (chezmoi, agent runtimes, and local helpers) win over
# package-manager copies. De-duplicate PATH while preserving its order.
typeset -U path PATH
path=("$HOME/.local/bin" $path)

# Historical host-specific tools; harmless on systems where the path is absent.
path+=/users/dholmes/bin
