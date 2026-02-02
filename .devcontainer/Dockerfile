# .devcontainer/Dockerfile
# Builds a devcontainer image with chezmoi and mise installed.
# Does not apply or modify dotfiles automatically.
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    file \
    git \
    gnupg \
    procps \
    sudo \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsLS https://mise.run \
  | MISE_INSTALL_PATH=/usr/local/bin/mise sh

RUN curl -fsLS https://get.chezmoi.io \
  | sh -s -- -b /usr/local/bin

RUN groupadd --gid 1000 taylor \
  && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash taylor \
  && echo "taylor ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/taylor \
  && chmod 0440 /etc/sudoers.d/taylor

CMD ["sleep", "infinity"]
