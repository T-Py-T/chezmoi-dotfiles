# NeoVim Configuration Migration Task

## Objective
Use ThePrimeagen's neovimrc setup as the primary configuration, adding only our custom plugins on top.

## Current Status: Phase 2 - COMPLETED ✓ | Phase 3 - IN PROGRESS

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

## Phase 2: Plugin Migration - COMPLETED ✓
- [x] Create lua/local/lazy.lua (ThePrimeagen's lazy_init)
- [x] Replace telescope.lua with ThePrimeagen's version
- [x] Replace lspconfig.lua with ThePrimeagen's LSP setup (with pyright, gopls added)
- [x] Replace mason.lua with ThePrimeagen's mason
- [x] Replace treesitter.lua with ThePrimeagen's version (added python, go, bash, json, yaml)
- [x] Replace colorscheme.lua with ThePrimeagen's colors (rose-pine + tokyonight)
- [x] Keep plugins init.lua (base plugins: plenary, tmux-navigator)
- [x] Keep our 5 custom plugins (harpoon, oil, trouble, spectre, copilot)
- [x] Tested: NeoVim loads without errors, plugins downloading on first start

## Phase 3: Clean Up - IN PROGRESS
- [ ] Remove duplicate/unused plugin files from old setup
- [ ] Delete old keymaps.lua (now remap.lua) if it still exists
- [ ] Verify all Lua files follow new structure
- [ ] Quick local verification test

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

