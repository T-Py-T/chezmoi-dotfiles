# .devcontainer/Dockerfile
# Minimal bootstrap image: installs only what is needed to run Homebrew, mise, and chezmoi.
# All other packages (neovim, ripgrep, fzf, etc.) are installed via brew/devcontainer/Brewfile
# during the postStartCommand (startup.sh -> chezmoi apply -> run_10_homebrew).
# Does not apply or modify dotfiles automatically.

FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

# Minimum packages required to bootstrap Homebrew on Linux.
# Homebrew needs: bash, build-essential, ca-certificates, curl, file, git, procps.
# zsh: default user shell.
# ncurses-bin: provides infocmp, needed by nvim terminal health check.
# sudo: allows the taylor user to install packages.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    curl \
    file \
    git \
    ncurses-bin \
    procps \
    sudo \
    zsh \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsLS https://mise.run \
  | MISE_INSTALL_PATH=/usr/local/bin/mise sh

RUN curl -fsLS https://get.chezmoi.io \
  | sh -s -- -b /usr/local/bin

# Install NeoVim directly from release.
# NeoVim is also in the devcontainer Brewfile but installing it here ensures
# it is available before chezmoi/Homebrew run, so startup.sh can bootstrap plugins.
RUN mkdir -p /tmp/nvim && cd /tmp/nvim \
  && curl -fLo nvim.tar.gz https://github.com/neovim/neovim/releases/download/v0.11.6/nvim-linux-arm64.tar.gz \
  && tar xzf nvim.tar.gz \
  && mv nvim-linux-arm64/bin/nvim /usr/local/bin/ \
  && mv nvim-linux-arm64/lib/nvim /usr/local/lib/ \
  && mv nvim-linux-arm64/share/nvim /usr/local/share/ \
  && rm -rf /tmp/nvim

RUN groupadd --gid 1000 taylor \
  && useradd --uid 1000 --gid 1000 --create-home --shell /bin/zsh taylor \
  && echo "taylor ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/taylor \
  && chmod 0440 /etc/sudoers.d/taylor

CMD ["sleep", "infinity"]
