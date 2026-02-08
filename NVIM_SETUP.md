# NeoVim Setup Instructions

## Quick Start

After deploying the chezmoi configuration, your NeoVim setup includes IDE-quality plugins.

## First Launch

When you open `nvim` for the first time:

1. Lazy.nvim will auto-install all plugins
2. Mason (LSP installer) can auto-install language servers
3. Treesitter will compile syntax parsers on first load

This may take 2-3 minutes on first startup.

## Language Server Setup

### Option 1: Auto-install with Mason

```vim
:Mason
```

Then search and install language servers:
- `pyright` or `pylsp` for Python
- `gopls` for Go
- `rust-analyzer` for Rust
- `typescript-language-server` for TypeScript/JavaScript

### Option 2: Manual Installation

Language servers can be installed via `mise`:
```bash
# Already available via mise:
# Python - included with python
# Go - included with go
# Rust - included with rust
```

## GitHub Copilot Setup

If you want to use Copilot:

1. Install the Copilot plugin (already in config):
   ```vim
   :Copilot setup
   ```

2. Authenticate with GitHub when prompted

3. Use with `<C-;>` to accept suggestions

## Optional: Additional Setup

### Fonts (Optional)
Install a Nerd Font for better icons:
- Download from: https://www.nerdfonts.com/
- Recommended: FiraCode Nerd Font, JetBrains Mono Nerd Font

### External Tools
Some plugins work better with external tools:

```bash
# Already installed via mise:
fzf          # Faster telescope searches
ripgrep      # Better grep replacement (in telescope)

# Optional external installations:
lazygit      # Better git UI (already in mise)
```

## Quick Reference

### Open NeoVim Dashboard
```bash
nvim
```

First screen shows recent files and bookmarks.

### Quick Navigation
- `<leader>ff` - Find files
- `<leader>fs` - Search content
- `<leader>ha` - Add file to harpoon
- `<leader>hh` - See harpoon marks

### LSP Commands
- `<leader>fd` - Show diagnostics
- `<leader>fw` - Workspace symbols
- `gR` - Find references
- `gd` - Go to definition

### Version Numbers

Current plugin versions (auto-managed):
- Neovim: 0.11.6 (via mise)
- Lazy.nvim: Latest
- Harpoon: Branch harpoon2
- Telescope: 0.1.x
- All others: Latest

## Updating Plugins

Plugins auto-update on startup. To manually update:

```vim
:Lazy update
```

## Troubleshooting

### Plugins not loading?
```vim
:Lazy sync
```

### LSP not working?
```vim
:LspInfo
:Mason
```

### Slow startup?
Check with:
```vim
:Lazy profile
```

### Missing icons?
Install a Nerd Font or set:
```vim
:set termguicolors
```

## File Locations

Configuration files are managed by chezmoi:
- Location: `~/.config/nvim/`
- Source: `dot_config/nvim/` in chezmoi repository
- Apply changes: `chezmoi apply`
- Edit locally: `chezmoi edit ~/.config/nvim/init.lua`

## Support

For plugin documentation:
- Harpoon: https://github.com/ThePrimeagen/harpoon
- Telescope: https://github.com/nvim-telescope/telescope.nvim
- Oil: https://github.com/stevearc/oil.nvim
- Trouble: https://github.com/folke/trouble.nvim
- Spectre: https://github.com/nvim-pack/nvim-spectre
- Copilot: https://github.com/github/copilot.vim

## ThePrimeagen's Setup

This configuration is inspired by ThePrimeagen's neovimrc:
- Repository: https://github.com/ThePrimeagen/neovimrc
- Modular architecture for maintainability
- Focus on productivity tools (Harpoon, Telescope)
- Clean LSP setup
