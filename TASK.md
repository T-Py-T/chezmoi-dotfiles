# NeoVim Configuration Migration Task

## Objective
Migrate to ThePrimeagen's neovimrc setup while preserving our custom enhancements and ensuring stability.

## Current Status: IN PROGRESS

## Strategy
- Favor ThePrimeagen's setup by default
- Preserve custom configs if not in ThePrimeagen's setup
- Comment out keybindings that conflict
- Keep all plugins that exist in our setup but not in his

## Phase 1: Core Setup - DONE
- [x] Add ripgrep to mise.toml (DONE)
- [x] Create init.lua (just requires local module) (DONE)
- [x] Create lua/local/core/set.lua with ThePrimeagen's settings (DONE as options.lua)
- [x] Create lua/local/core/remap.lua with ThePrimeagen's keymaps (DONE - merged with ours)
- [x] Update lua/local/init.lua with autocmds from ThePrimeagen (DONE)
- [ ] Create lua/local/lazy_init.lua for lazy.nvim setup (NEXT)

## Phase 2: Plugin Migration
- [ ] Fetch ThePrimeagen's lazy plugin specs
- [ ] Migrate telescope.lua
- [ ] Migrate lsp configs (lspconfig.lua, mason.lua)
- [ ] Migrate treesitter.lua
- [ ] Migrate colorscheme.lua
- [ ] Migrate other plugins from his setup
- [ ] Keep our custom plugins (harpoon, oil, trouble, spectre, copilot)

## Phase 3: Keybinding Audit
- [ ] Merge ThePrimeagen's keymaps with ours
- [ ] Comment out conflicts
- [ ] Ensure no duplicate mappings
- [ ] Test all keybindings

## Phase 4: Testing
- [ ] Full rebuild of devpod
- [ ] Test all plugins load
- [ ] Verify LSP works
- [ ] Test Telescope/Harpoon/Oil
- [ ] Verify custom keybindings

## Preserved Customs (Won't Delete)
- Harpoon plugin (not in ThePrimeagen's latest)
- Oil file explorer (our addition)
- Trouble diagnostics (our addition)
- Spectre find/replace (our addition)
- Copilot (our addition)
- Custom shell aliases keymaps

## Dependencies to Install
- ripgrep ✓ (ADDED to mise)
- Everything else already available

## ThePrimeagen's Core Files to Integrate
1. **set.lua** - Editor settings (vim.opt configs)
2. **remap.lua** - Core keybindings
3. **init.lua** - Autocmds and special setup
4. **lazy_init.lua** - Lazy.nvim initialization

## Files Structure After Migration
```
lua/local/
├── core/
│   ├── init.lua (+ ThePrimeagen's autocmds)
│   ├── keymaps.lua (merged with ThePrimeagen's)
│   ├── options.lua (from ThePrimeagen's set.lua)
│   └── remap.lua (ThePrimeagen's core remaps)
├── lazy.lua (lazy_init from ThePrimeagen)
└── plugins/ (existing + ThePrimeagen's)
```

## Notes
- ThePrimeagen uses relative line numbers (we can keep)
- His tab settings: 4 spaces
- His colorcolumn: 80 chars
- His special keymaps: mostly LSP and workflow optimizations
