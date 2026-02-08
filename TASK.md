# NeoVim Configuration Migration Task

## Objective
Use ThePrimeagen's neovimrc setup as the primary configuration, adding only our custom plugins on top.

## Current Status: Phase 2 - IN PROGRESS

## Strategy
- Replace our complex setup with ThePrimeagen's proven, simpler setup
- Keep ONLY our custom plugins: Harpoon, Oil, Trouble, Spectre, Copilot
- Use his plugin structure and philosophy
- Simplify to the essentials

## Phase 1: Core Setup - DONE ✓
- [x] Add ripgrep to mise.toml
- [x] Update options.lua with ThePrimeagen's settings
- [x] Create remap.lua with ThePrimeagen's keybindings
- [x] Update init.lua with ThePrimeagen's autocmds

## Phase 2: Plugin Migration - IN PROGRESS
- [ ] Create lua/local/lazy.lua (ThePrimeagen's lazy_init)
- [ ] Replace telescope.lua with ThePrimeagen's version
- [ ] Replace lspconfig.lua with ThePrimeagen's LSP setup
- [ ] Replace mason.lua with ThePrimeagen's mason
- [ ] Replace treesitter.lua with ThePrimeagen's version
- [ ] Replace colorscheme.lua with ThePrimeagen's colors
- [ ] Keep plugins init.lua (base plugins)
- [ ] Delete redundant plugins we're not using
- [ ] Keep our 5 custom plugins (harpoon, oil, trouble, spectre, copilot)

## Phase 3: Clean Up
- [ ] Remove duplicate/unused plugin files
- [ ] Delete old keymaps.lua (now remap.lua)
- [ ] Verify all plugins load
- [ ] Test core functionality

## Phase 4: Testing
- [ ] Full rebuild of devpod
- [ ] Test all plugins load
- [ ] Verify LSP works
- [ ] Verify custom plugins work
- [ ] Commit all changes

## Preserved Custom Plugins (Will Keep)
1. Harpoon - Quick file navigation
2. Oil - File explorer
3. Trouble - Diagnostics viewer
4. Spectre - Find and replace
5. Copilot - AI suggestions

## ThePrimeagen's Key Plugins (Will Use)
- Telescope - Fuzzy finder
- Treesitter - Syntax highlighting
- LSP Zero (maybe) or direct nvim-lspconfig
- Mason - LSP installer
- Colorscheme (nightfly or similar)
- nvim-cmp - Completions
- Various quality-of-life plugins

## Dependencies Met
- ripgrep ✓
- All language servers via mise ✓
- Build tools in Dockerfile ✓

