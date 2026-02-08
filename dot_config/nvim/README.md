# NeoVim Configuration

Professional IDE-like NeoVim setup inspired by ThePrimeagen's configuration, with modular plugin architecture for easy maintenance.

## Architecture

The configuration follows a clean modular structure:

```
~/.config/nvim/
├── init.lua                      # Main entry point
└── lua/local/
    ├── core/
    │   ├── init.lua             # Load core modules
    │   ├── options.lua          # Editor settings
    │   ├── keymaps.lua          # Leader key mappings
    │   └── init.lua             # Startup code
    ├── lazy.lua                 # Lazy.nvim plugin manager setup
    └── plugins/
        ├── init.lua             # Base plugins (plenary, tmux-navigator)
        ├── alpha.lua            # Startup screen
        ├── telescope.lua        # Fuzzy finder
        ├── harpoon.lua          # Quick file navigation
        ├── oil.lua              # File explorer
        ├── trouble.lua          # Diagnostics viewer
        ├── spectre.lua          # Find and replace
        ├── copilot.lua          # AI code suggestions
        ├── lsp/
        │   ├── lspconfig.lua    # Language servers
        │   └── mason.lua        # LSP installer
        ├── treesitter.lua       # Syntax highlighting
        ├── nvim-cmp.lua         # Completions
        ├── autopairs.lua        # Auto bracket pairing
        ├── comment.lua          # Code commenting
        ├── gitsigns.lua         # Git integration
        ├── lazygit.lua          # Git UI
        ├── colorscheme.lua      # Theme
        ├── lualine.lua          # Status line
        ├── bufferline.lua       # Buffer tabs
        └── ... other plugins
```

## Key Features

### 1. Harpoon - Quick Navigation
Jump between your most-used files instantly.

**Keymaps:**
- `<leader>ha` - Add current file to harpoon
- `<leader>hh` - Toggle harpoon menu
- `<leader>h1-9` - Jump to harpoon file 1-9
- `<leader>hn` - Next harpoon file
- `<leader>hp` - Previous harpoon file

### 2. Telescope - Fuzzy Finder
Powerful search and navigation tool.

**Keymaps:**
- `<leader>ff` - Find files
- `<leader>fr` - Recent files
- `<leader>fs` - Live grep (search content)
- `<leader>fc` - Find word under cursor
- `<leader>fb` - Buffers
- `<leader>fh` - Help tags
- `<leader>fk` - Keymaps
- `<leader>fd` - Diagnostics
- `<leader>ft` - TODOs
- `<leader>fgc` - Git commits
- `<leader>fgs` - Git status
- `<leader>fgb` - Git branches

### 3. Oil - File Explorer
Browse and manipulate files easily.

**Keymaps:**
- `-` or `<leader>-` - Open oil file explorer

### 4. Trouble - Diagnostics
View LSP diagnostics, quickfix, and location lists.

**Keymaps:**
- `<leader>xx` - Toggle trouble list
- `<leader>xw` - Workspace diagnostics
- `<leader>xd` - Document diagnostics
- `<leader>xq` - Quickfix
- `<leader>xl` - Location list
- `gR` - LSP references

### 5. Spectre - Find and Replace
Advanced find and replace functionality.

**Keymaps:**
- `<leader>ss` - Open spectre
- `<leader>sw` - Find and replace word

### 6. Copilot - AI Code Completion
GitHub Copilot integration for intelligent suggestions.

**Keymaps:**
- `<C-;>` - Accept copilot suggestion
- `<C-]>` - Dismiss copilot suggestion

## General Keymaps

### Navigation
- `jk` (insert mode) - Exit insert mode
- `<C-w>v` - Split vertically
- `<C-w>s` - Split horizontally
- `<C-w>=` - Make splits equal
- `<C-w>x` - Close split
- `<leader>nh` - Clear highlights

### Tabs
- `<leader>to` - New tab
- `<leader>tx` - Close tab
- `<leader>tn` - Next tab
- `<leader>tp` - Previous tab
- `<leader>tf` - Current buffer to new tab

### Numbers
- `<leader>+` - Increment number
- `<leader>-` - Decrement number

### Tmux Integration
- `<C-\>` - Navigate between tmux and vim panes seamlessly

## Installation

The configuration is managed via `chezmoi`. All files in `~/.config/nvim/` are automatically deployed.

## Adding New Plugins

1. Create a new file in `lua/local/plugins/plugin-name.lua`
2. Follow the lazy.nvim spec:

```lua
return {
  "author/plugin-name",
  dependencies = { "other/plugin" },
  config = function()
    require("plugin").setup({ ... })
    -- Add keymaps here
  end,
}
```

3. Plugin will auto-load on next startup

## ThePrimeagen Inspiration

This configuration draws inspiration from ThePrimeagen's `neovimrc`:
- Modular plugin architecture
- Harpoon for file navigation
- Telescope for fuzzy finding
- LSP Zero for language server setup
- Clean, organized keymaps
- Lazy.nvim for fast startup

## Performance Notes

- Lazy loading via lazy.nvim for fast startup
- Minimal core dependencies
- Plugins load on-demand
- fzf native extension for blazing fast searching

## Customization

Most plugins can be customized by editing their respective files in `lua/local/plugins/`.

For editor settings, modify `lua/local/core/options.lua`.

For keymaps, either add to `lua/local/core/keymaps.lua` or the specific plugin file.
