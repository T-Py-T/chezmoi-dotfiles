# .devcontainer/Dockerfile
# Builds a devcontainer image with chezmoi and mise installed.
# Does not apply or modify dotfiles automatically.
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    git \
    gnupg \
  && install -dm 755 /etc/apt/keyrings \
  && curl -fSs https://mise.jdx.dev/gpg-key.pub \
    | gpg --dearmor -o /etc/apt/keyrings/mise-archive-keyring.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg] https://mise.jdx.dev/deb stable main" \
    > /etc/apt/sources.list.d/mise.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    chezmoi \
    mise \
  && rm -rf /var/lib/apt/lists/*
