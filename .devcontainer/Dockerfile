# .devcontainer/Dockerfile
# Minimal bootstrap image: installs only what is needed to run Homebrew, mise, and chezmoi.
# All other packages (neovim, ripgrep, fzf, etc.) are installed via brew/devcontainer/Brewfile
# during the postStartCommand (startup.sh -> chezmoi apply -> run_10_homebrew).
# Does not apply or modify dotfiles automatically.

FROM ubuntu:noble@sha256:224a1869083a311ef3f13648a154ba79832fbef6364d31493642ca03082da254

ENV DEBIAN_FRONTEND=noninteractive
# C.UTF-8 ships with Ubuntu Noble by default. Setting LANG/LC_ALL silences
# `checkhealth` locale errors and ensures unicode renders correctly for nvim,
# starship, eza, etc. TERM default prevents `infocmp` failures when nvim runs
# headlessly (no TTY attached).
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TERM=xterm-256color

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

ARG MISE_VERSION=v2026.9.6
ARG MISE_SHA256=7892401c3a3b8166e8be3a3bbd564f48b36946e580e031f2df94a4935edfd907
RUN curl -fsSL \
    "https://github.com/jdx/mise/releases/download/${MISE_VERSION}/mise-${MISE_VERSION}-linux-arm64" \
    -o /tmp/mise \
  && echo "${MISE_SHA256}  /tmp/mise" | sha256sum --check --strict \
  && install -m 0755 /tmp/mise /usr/local/bin/mise \
  && rm /tmp/mise

ARG CHEZMOI_VERSION=2.72.1
ARG CHEZMOI_SHA256=75508ef41216b6d64f3145986b751729d7f92d09c6bad77d51cf2895ab35a508
RUN curl -fsSL \
    "https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION}/chezmoi_${CHEZMOI_VERSION}_linux_arm64.tar.gz" \
    -o /tmp/chezmoi.tar.gz \
  && echo "${CHEZMOI_SHA256}  /tmp/chezmoi.tar.gz" | sha256sum --check --strict \
  && tar -xzf /tmp/chezmoi.tar.gz -C /tmp chezmoi \
  && install -m 0755 /tmp/chezmoi /usr/local/bin/chezmoi \
  && rm /tmp/chezmoi /tmp/chezmoi.tar.gz

# Install NeoVim directly from release.
# 0.12.5 is the current stable; required by init.lua (vim.pack plugin manager,
# vim.lsp.enable, vim.lsp.completion.enable). 0.13 is nightly-only as of this writing.
# NeoVim is also in the devcontainer Brewfile but installing it here ensures
# it is available before chezmoi/Homebrew run, so startup.sh can bootstrap plugins.
ARG NVIM_VERSION=v0.12.5
ARG NVIM_SHA256=1aa5ca085249580ae0f91eb14f27ec0919773ff2d99a163d03f3d6c21ac29725
RUN mkdir -p /tmp/nvim && cd /tmp/nvim \
  && curl -fLo nvim.tar.gz "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-arm64.tar.gz" \
  && echo "${NVIM_SHA256}  nvim.tar.gz" | sha256sum --check --strict \
  && tar xzf nvim.tar.gz \
  && mv nvim-linux-arm64/bin/nvim /usr/local/bin/ \
  && mv nvim-linux-arm64/lib/nvim /usr/local/lib/ \
  && mv nvim-linux-arm64/share/nvim /usr/local/share/ \
  && rm -rf /tmp/nvim

RUN existing_user="$(getent passwd 1000 | cut -d: -f1 || true)" \
  && if [ -n "$existing_user" ]; then userdel "$existing_user"; fi \
  && existing_group="$(getent group 1000 | cut -d: -f1 || true)" \
  && if [ -n "$existing_group" ]; then \
       groupmod --new-name taylor "$existing_group"; \
     else \
       groupadd --gid 1000 taylor; \
     fi \
  && useradd --uid 1000 --gid 1000 --create-home --shell /bin/zsh taylor \
  && echo "taylor ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/taylor \
  && chmod 0440 /etc/sudoers.d/taylor

CMD ["sleep", "infinity"]
