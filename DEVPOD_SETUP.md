# DevPod + NeoVim/NvChad Setup: Complete Guide

## Project Overview

This repository contains a complete, production-ready DevPod development environment with:
- **Containerized via DevPod**: Lightweight, fast, reproducible development workspace
- **NvChad + Kickstart NeoVim**: Polished IDE with your custom configuration
- **mise for tooling**: Language runtimes (Python, Go, Rust, Node.js) installed via `mise`
- **chezmoi for dotfiles**: Automatic configuration management

## Quick Start

### Access the DevPod
```bash
devpod ssh dev
```

### Initialize Environment
```bash
# Trust mise configuration
mise trust --yes

# Activate mise tools
eval "$(mise activate zsh)"

# Launch NeoVim
nvim
```

## Architecture

### File Organization

```
chezmoi-dotfiles/
├── .devcontainer/
│   ├── Dockerfile         # Container image definition
│   └── devcontainer.json  # DevPod configuration
├── dot_config/
│   ├── nvim/              # NeoVim configuration (NvChad + Kickstart)
│   ├── bash/              # Bash configuration
│   ├── zsh/               # Zsh configuration
│   ├── shell_aliases      # Shared shell aliases
│   └── tmux.conf          # Tmux configuration
├── scripts/
│   ├── devpod-up.sh       # Rebuild devpod helper
│   └── run_10_homebrew    # Homebrew configuration (skipped in containers)
├── mise.toml              # Tool versions and configuration
└── NVIM_SETUP.md          # NeoVim detailed documentation
```

## Technologies

### Language Runtimes (via mise)
- **Python** 3.14.3 - Data science, backend development
- **Go** 1.25.7 - Systems programming, CLI tools
- **Rust** 1.93.0 - Systems programming, performance
- **Node.js** 22.12.0 - JavaScript/TypeScript development

### NeoVim Configuration
- **NvChad** - Modern framework with themes, UI, and plugins
- **Kickstart** - Your custom settings, keybindings, and tweaks
- **Mason** - LSP server, formatter, and linter management
- **Tree-sitter** - Syntax highlighting and code understanding
- **Telescope** - Fuzzy finder for files, grep, and more

### System Packages (in Dockerfile)
```
bash, build-essential, ca-certificates, cmake,
coreutils, curl, file, gcc, git, gnupg, libtool,
libtool-bin, ninja-build, pkg-config, procps,
sudo, wget, zsh
```

These are required for:
- NeoVim LSP server compilation
- Plugin native module building
- Tree-sitter parser compilation
- General development tasks

## Customization

### Adding Language Support
1. **Update mise.toml** with language runtime
2. **Configure LSP** in NeoVim via Mason (`:Mason` command)
3. **Add formatters/linters** as needed

### Customizing NeoVim
- **Settings**: `dot_config/nvim/lua/custom/settings.lua`
- **Keybindings**: `dot_config/nvim/lua/custom/mappings.lua`
- **Plugins**: Create `dot_config/nvim/lua/custom/plugins.lua`

### Modifying Dotfiles
All configurations in `dot_config/` are automatically applied via chezmoi on devpod startup.

## Performance Characteristics

- **Container Size**: ~600MB (with all dependencies)
- **Startup Time**: ~30-60 seconds (full devpod build)
- **NeoVim Launch**: <1 second
- **Memory Footprint**: Minimal (shared between processes)

## Troubleshooting

### NeoVim won't start
```bash
devpod ssh dev
mise trust --yes
nvim --version  # Verify NeoVim is installed
```

### Tools not found
```bash
devpod ssh dev
eval "$(mise activate zsh)"
which python3  # Verify mise activation
```

### Container build fails
```bash
devpod up . --reset  # Full rebuild
# Or specify custom ID:
devpod up . --reset --id dev
```

### Slow performance
- Check available disk space
- Clear NeoVim cache: `rm -rf ~/.local/share/nvim/`
- Rebuild container: `devpod up . --reset`

## Common Workflows

### Python Development
```bash
devpod ssh dev
eval "$(mise activate zsh)"
python3 --version
nvim script.py
```

### Go Development
```bash
devpod ssh dev
eval "$(mise activate zsh)"
go version
nvim main.go
```

### Node.js Development
```bash
devpod ssh dev
eval "$(mise activate zsh)"
node --version
npm init
nvim app.js
```

## Advanced Configuration

### Adding Custom Plugins to NeoVim
Create `dot_config/nvim/lua/custom/plugins.lua`:
```lua
return {
  {
    "plugin-user/plugin-name",
    opts = { setting = true },
  },
}
```

### Environment Variables
Edit `dot_config/zsh/*` or `dot_config/bash/*` files to set custom variables.

### Shell Aliases
Edit `dot_config/shell_aliases` for shared aliases across bash and zsh.

## Maintenance

### Updating Tool Versions
1. Edit `mise.toml` with new version numbers
2. Rebuild: `devpod up . --reset`

### Backing Up Configuration
Your `chezmoi-dotfiles` directory is the backup - commit to git!

### Cleaning Up
```bash
# Remove cached files
devpod delete dev
# Rebuild fresh
devpod up . --reset
```

## Next Steps

1. **SSH into devpod**: `devpod ssh dev`
2. **Trust mise**: `mise trust --yes`
3. **Launch NeoVim**: `nvim`
4. **Read NvChad docs**: `:help nvchad` in NeoVim
5. **Customize as needed**: Edit files in `dot_config/`

## Resources

- [NvChad Documentation](https://nvchad.com)
- [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [mise Documentation](https://mise.jdx.dev)
- [chezmoi Documentation](https://www.chezmoi.io)
- [DevPod Documentation](https://devpod.sh)
