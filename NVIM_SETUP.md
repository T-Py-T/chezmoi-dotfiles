# NeoVim Configuration: NvChad + Kickstart

## Overview

This NeoVim setup combines the best of both worlds:
- **NvChad**: Modern IDE framework with batteries-included (themes, UI, plugins)
- **Kickstart**: Your familiar custom settings, keybindings, and workflow

## Structure

```
dot_config/nvim/
├── lua/
│   ├── nvchad/           # NvChad base configuration (do not modify)
│   │   ├── plugins/
│   │   ├── configs/
│   │   ├── mappings.lua
│   │   └── options.lua
│   └── custom/           # Your customizations go here
│       ├── chadrc.lua    # NvChad + custom settings integration
│       ├── init.lua      # Custom initialization (loads settings, mappings)
│       ├── settings.lua  # vim.o/vim.opt from kickstart
│       ├── mappings.lua  # Custom keybindings
│       └── kickstart_init.lua  # Full kickstart config (reference)
├── init.lua              # NvChad entry point (loads custom/chadrc.lua)
└── ...
```

## Custom Keybindings

Your kickstart keybindings are preserved in `lua/custom/mappings.lua`:

### Navigation
- `<C-h/j/k/l>` - Move between splits

### Telescope (Search)
- `<leader>sf` - Find files
- `<leader>sg` - Live grep
- `<leader>sw` - Search word under cursor
- `<leader>sh` - Search help
- `<leader>sk` - Search keymaps

### LSP
- `grn` - Rename symbol
- `gra` - Code action
- `grD` - Goto declaration
- `<leader>th` - Toggle inlay hints

### General
- `<Esc>` - Clear search highlighting
- `<leader>q` - Open diagnostics

## Adding Custom Plugins

To add plugins while keeping NvChad:

1. Create `lua/custom/plugins.lua`:
```lua
return {
  {
    "user/plugin-name",
    opts = {},
    config = function(_, opts)
      -- setup code
    end
  }
}
```

2. NvChad will automatically load plugins from `lua/custom/plugins.lua`

## Customizing Settings

Edit `lua/custom/settings.lua` to adjust:
- vim.o options (number, mouse, clipboard, etc.)
- Tab size, indentation
- UI preferences

## Using NvChad Features

NvChad includes many useful commands:
- `:Telescope` - Launch telescope search
- `:NvimTreeToggle` - Toggle file explorer
- `:Mason` - Package manager for LSP/formatters/linters
- `:checkhealth` - Diagnose configuration

## Switching Back to Kickstart

If you want to use the full kickstart config:
```bash
cp dot_config/nvim.backup/init.lua dot_config/nvim/init.lua
```

## Performance

This setup is optimized for:
- Fast startup (uses lazy loading)
- Minimal memory footprint
- Responsive UI with catppuccin theme

## Troubleshooting

### NvChad not loading custom config
Make sure `lua/custom/init.lua` and `lua/custom/chadrc.lua` exist

### Keybindings not working
Check that `lua/custom/mappings.lua` exists and is being loaded by `init.lua`

### Plugins not installing
Run `:Mason` to check if all dependencies are installed
