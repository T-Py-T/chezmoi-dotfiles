-- dot_config/nvim/init.lua
-- Neovim 0.12.2 config based on github.com/y9san9/y9san9.nvim with local tweaks.
-- Does not configure Mason, blink.cmp, telescope, conform, mini, or gitsigns.
-- 0.13-only APIs (vim._core.ui2, packadd nvim.undotree/nvim.difftool) commented out.

vim.pack.add({
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/ThePrimeagen/vim-be-good',
  -- 'https://github.com/y9san9/y9nika.nvim',
  -- 'https://github.com/wakatime/vim-wakatime',
  -- 'https://github.com/vyfor/cord.nvim',
})

vim.cmd.packadd('cfilter')
-- vim.cmd.packadd('nvim.undotree')   -- 0.13-only built-in package
-- vim.cmd.packadd('nvim.difftool')   -- 0.13-only built-in package

-- 0.13-only message-area UI; uncomment when nightly/0.13 stable is the runtime.
-- require('vim._core.ui2').enable {
--   msg = {
--     target = 'msg',
--     msg = {
--       height = 0.0001,
--       width = 1,
--       timeout = 2000,
--     },
--   }
-- }

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.exrc = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.colorcolumn = '80'
vim.opt.textwidth = 80
vim.opt.completeopt = 'menu,menuone,fuzzy,noinsert'
vim.opt.swapfile = false
vim.opt.confirm = true
vim.opt.linebreak = true
vim.opt.termguicolors = true
vim.opt.wildoptions:append({ 'fuzzy' })
vim.opt.nrformats:append({ 'blank', 'alpha' })
vim.opt.path:append({ '**' })
vim.opt.smoothscroll = true
vim.opt.grepprg = 'rg --vimgrep --no-messages --smart-case'
vim.opt.statusline = '[%n] %<%f %h%w%m%r%=%-14.(%l,%c%V%) %P'
vim.opt.foldlevel = 999
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.guifont = 'JetBrainsMono Nerd Font:h35'
vim.opt.tabstop = 4

require('tokyonight').setup({
  styles = { comments = { italic = false } },
})
vim.cmd.colorscheme('tokyonight-night')

-- disable mouse popup yet keep mouse enabled
vim.cmd([[
  aunmenu PopUp
  autocmd! nvim.popupmenu
]])

-- Only highlight with treesitter
vim.cmd('syntax off')

require('oil').setup({
  keymaps = { ['<C-h>'] = false },
  columns = { 'size', 'mtime' },
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
})

-- Popup hints for prefix keys (<leader>, [, ], d, g, z, ...). Auto-discovers
-- existing keymaps. helix preset shows key + description + group in a side
-- panel, best for learning. Default icons enabled (requires nerd font in terminal).
require('which-key').setup({
  preset = 'helix',
  delay = 200,
})

-- Keymaps
vim.keymap.set('n', '<leader><leader>', ':Oil<CR>', { silent = true })

vim.keymap.set('n', '<leader>a', function()
  vim.cmd('$argadd %')
  vim.cmd('argdedup')
end)
vim.keymap.set('n', '<C-h>', function()
  vim.cmd('silent! 1argument')
end)
vim.keymap.set('n', '<C-j>', function()
  vim.cmd('silent! 2argument')
end)
vim.keymap.set('n', '<C-k>', function()
  vim.cmd('silent! 3argument')
end)
vim.keymap.set('n', '<C-n>', function()
  vim.cmd('silent! 4argument')
end)
vim.keymap.set('n', '<C-m>', function()
  vim.cmd('silent! 5argument')
end)

-- LSP servers
-- nvim-lspconfig ships pre-defined configs that activate via vim.lsp.enable.
-- Server binaries must be on $PATH (gopls via go install, pyright via brew).
vim.lsp.enable('gopls')
vim.lsp.enable('pyright')

-- Autocommands
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.o.signcolumn = 'yes:1'
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/completion') then
      vim.o.complete = 'o,.,w,b,u'
      vim.o.completeopt = 'menu,menuone,popup,noinsert'
      vim.lsp.completion.enable(true, client.id, args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
})
