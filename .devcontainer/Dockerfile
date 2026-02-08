# .devcontainer/Dockerfile
# Builds a lightweight devcontainer with mise and chezmoi.
# Uses Alpine Linux for minimal size (~80MB vs 500MB+ with Ubuntu).
# Does not apply or modify dotfiles automatically.
FROM alpine:latest

RUN apk add --no-cache \
    bash \
    zsh \
    ca-certificates \
    curl \
    git \
    coreutils \
    procps \
    sudo \
    build-base

RUN curl -fsLS https://mise.run \
  | MISE_INSTALL_PATH=/usr/local/bin/mise sh

RUN curl -fsLS https://get.chezmoi.io \
  | sh -s -- -b /usr/local/bin

RUN addgroup -g 1000 taylor \
  && adduser -D -u 1000 -G taylor -s /bin/zsh taylor \
  && echo "taylor ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/taylor \
  && chmod 0440 /etc/sudoers.d/taylor

CMD ["sleep", "infinity"]
