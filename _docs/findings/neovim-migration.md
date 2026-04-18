# Neovim Configuration History

Record of the editor config evolution in this repo. Useful when deciding whether to refactor again, and to avoid re-litigating settled decisions.

## Current state (April 2026)

- Base: **kickstart.nvim** (`init.lua` ~880 lines, deliberately readable end-to-end).
- Plugin manager: `lazy.nvim` (kickstart's default).
- LSP: `nvim-lspconfig` + Mason for installer convenience. Configured Python and Go LSPs only.
- Layout:
  ```
  dot_config/nvim/
  ├── init.lua                       primary kickstart file
  ├── kickstart/
  │   ├── health.lua
  │   └── plugins/                   kickstart's optional plugins (autopairs, debug, gitsigns, indent_line, lint, neo-tree)
  ├── custom/
  │   └── plugins/init.lua           custom plugin slot (kickstart's intended extension point)
  └── lua/theprimeagen/              STALE — leftover from previous setup, not loaded by init.lua
  ```

## Evolution

### Phase 1 — ThePrimeagen's config (deprecated)

Initially attempted a 100% copy of ThePrimeagen's nvim setup. The `tasks/TASK.md` (now removed, content folded into this doc) declared this "complete" but in practice it was too complex to maintain — many bespoke keymaps, plugin combinations, and configuration patterns that required reading his videos to understand.

The `lua/theprimeagen/` directory still exists in the tree but is no longer loaded by `init.lua`. **It should be deleted.** Tracked under the upcoming nvim 0.12 refactor branch.

### Phase 2 — kickstart.nvim (current as of this writing)

Switched to kickstart.nvim because it is:
- Single-file (well, mostly) and readable top-to-bottom.
- Documented inline.
- Designed to be edited, not just copied.

This was a deliberate downgrade in feature complexity for an upgrade in maintainability. Decision was correct.

### Phase 3 — Neovim 0.12 + vim.pack (planned)

Neovim 0.12 was released March 29, 2026 with `vim.pack` (built-in plugin manager) and stronger built-in LSP support (`vim.lsp.config()` / `vim.lsp.enable()` from 0.11). This makes it possible to drop:
- `lazy.nvim` (replaced by `vim.pack`)
- Most of `nvim-lspconfig` (replaced by `vim.lsp.config()`)
- Parts of `nvim-cmp` (built-in autocomplete in 0.12)

**Chosen path: Path B — keep kickstart structure, swap `lazy.nvim` for `vim.pack`.**

Rationale:
- The kickstart structure is already what we want — well-organized, readable. Don't blow it up.
- Swapping the plugin manager is a contained refactor (~50% line reduction).
- Greenfield rewrite (Path C) would save more lines but means re-deciding every keymap and plugin choice. Not worth the time when kickstart's defaults are already sane.
- `vim.pack` is officially marked **experimental** in 0.12 docs. Worth knowing, not blocking.

The refactor will happen on its own branch (`feat/nvim-0.12-vim-pack` or similar) so the working main can be reverted to if anything goes sideways.

## Decisions worth preserving

- **No vim distros** (LazyVim, AstroNvim, LunarVim). Distros optimize for "looks impressive on YouTube" not "I understand every line."
- **Mason for LSP installers, not for the LSP servers themselves** in the long term. Once Path B lands, evaluate dropping Mason and using `vim.lsp.config()` against system-installed LSPs.
- **Two-Brewfile approach for nvim runtime deps.** `brew/linux/`, `brew/macos/`, and `brew/devcontainer/` all install `neovim`, `tree-sitter`, `luarocks`, `ripgrep`, `fd`, `fzf`. This duplication is intentional — see [deployment/devcontainer.md](../deployment/devcontainer.md).
- **`tree-sitter-cli` via npm in `dot_zshrc`** is a belt-and-suspenders fallback for environments where the Brewfile didn't land it. Harmless if redundant.

## Cleanup checklist for the 0.12 refactor branch

When the refactor lands:

- [ ] Delete `dot_config/nvim/lua/theprimeagen/` (stale).
- [ ] Migrate `init.lua` from `lazy.nvim` to `vim.pack`.
- [ ] Migrate LSP setup from `nvim-lspconfig` to `vim.lsp.config()` / `vim.lsp.enable()`.
- [ ] Reconsider Mason vs system-installed LSPs.
- [ ] Update this doc with the result and any gotchas hit.
- [ ] Delete `tasks/` directory (its sole content, `TASK.md`, has been folded here).
