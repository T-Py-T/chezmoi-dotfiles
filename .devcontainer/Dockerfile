# .devcontainer/Dockerfile
# Builds a lightweight devcontainer with chezmoi, mise, and NeoVim/NvChad.
# Uses ubuntu:jammy (~60MB slim variant) for smaller size while maintaining compatibility.
# Does not apply or modify dotfiles automatically.
FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    cmake \
    coreutils \
    curl \
    file \
    gcc \
    git \
    gnupg \
    libtool \
    libtool-bin \
    luarocks \
    ninja-build \
    pkg-config \
    procps \
    sudo \
    wget \
    zsh \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsLS https://mise.run \
  | MISE_INSTALL_PATH=/usr/local/bin/mise sh

RUN curl -fsLS https://get.chezmoi.io \
  | sh -s -- -b /usr/local/bin

# Install NeoVim directly from release (avoids GitHub rate limiting via vfox)
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
