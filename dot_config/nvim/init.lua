-- init.lua
-- kickstart-derived config migrated to Neovim 0.12's built-in vim.pack plugin manager.
-- See _docs/findings/neovim-migration.md for history and decisions.

if vim.fn.has('nvim-0.12') == 0 then
  error('Neovim 0.12+ required (uses vim.pack). Upgrade via Brewfile.')
end

-- Silence checkhealth warnings for providers we don't use
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Leader keys must be set before plugins load
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false

-- [[ Options ]]
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- Deferred to avoid slowing startup
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- [[ Diagnostics ]]
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = true,
  virtual_lines = false,
  jump = { float = true },
})

-- [[ Basic keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Autocmds ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Plugin build hooks ]]
-- MUST be registered BEFORE vim.pack.add() so install events are caught.
-- This replaces lazy.nvim's `build = 'make'` pattern.
vim.api.nvim_create_autocmd('PackChanged', {
  desc = 'Run native build steps after plugin install/update',
  group = vim.api.nvim_create_augroup('pack-build-hooks', { clear = true }),
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then
      return
    end
    -- telescope-fzf-native ships a C extension that must be compiled
    if name == 'telescope-fzf-native.nvim' and vim.fn.executable('make') == 1 then
      vim.system({ 'make' }, { cwd = ev.data.path }):wait()
    end
  end,
})

-- [[ Plugin installation ]]
-- vim.pack clones into ~/.local/share/nvim/site/pack/core/opt/
-- Lockfile at ~/.config/nvim/nvim-pack-lock.json (committed so pins are reproducible).
-- Loading order matters for dependencies: plugin A that requires B must list B first.
vim.pack.add({
  -- Theme (first so colorscheme loads before any UI is drawn)
  'https://github.com/folke/tokyonight.nvim',
  -- Completion backend (blink.cmp.get_lsp_capabilities is called during LSP setup)
  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/saghen/blink.cmp',
  -- LSP
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  -- Telescope and deps
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  -- Formatting
  'https://github.com/stevearc/conform.nvim',
  -- Utilities
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  -- Syntax
  'https://github.com/nvim-treesitter/nvim-treesitter',
})

-- [[ Colorscheme ]]
require('tokyonight').setup({
  styles = { comments = { italic = false } },
})
vim.cmd.colorscheme('tokyonight-night')

-- [[ Completion ]]
require('luasnip').setup({})
require('blink.cmp').setup({
  keymap = { preset = 'default' },
  appearance = { nerd_font_variant = 'mono' },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets' },
  },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
})

-- [[ LSP ]]
require('mason').setup()
require('fidget').setup()

-- Buffer-local LSP keymaps, inlay hints, and reference highlighting on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('user-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('user-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = 'user-lsp-highlight', buffer = event2.buf })
        end,
      })
    end

    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- LSP servers configured here get capabilities from blink.cmp and are enabled.
-- Server binaries are installed via Mason below.
local capabilities = require('blink.cmp').get_lsp_capabilities()

local servers = {
  pyright = {},
  gopls = {},
}

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, {
  'lua-language-server',
  'stylua',
  'clangd',
  'gopls',
  'pyright',
  'typescript-language-server',
  'ruby-lsp',
  'bash-language-server',
})
require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

for name, server in pairs(servers) do
  server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

-- lua_ls needs runtime paths to see nvim config files as library code
vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath('config')
        and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT',
        path = { 'lua/?.lua', 'lua/?/init.lua' },
      },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file('', true),
      },
    })
  end,
  settings = { Lua = {} },
})
vim.lsp.enable('lua_ls')

-- [[ Telescope ]]
require('telescope').setup({
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
})
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep({
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  })
end, { desc = '[S]earch [/] in Open Files' })

vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files({ cwd = vim.fn.stdpath('config') })
end, { desc = '[S]earch [N]eovim files' })

-- Telescope-powered LSP navigation keymaps (per-buffer on attach)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
  end,
})

-- [[ Autoformat ]]
require('conform').setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- c/cpp have no standardized style — skip format-on-save
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    -- Add more as formatters are installed:
    -- python = { 'black' }, javascript = { 'prettier' },
    -- go = { 'goimports' }, rust = { 'rustfmt' }, etc.
  },
})
vim.keymap.set('', '<leader>f', function()
  require('conform').format({ async = true, lsp_format = 'fallback' })
end, { desc = '[F]ormat buffer' })

-- [[ Utilities ]]
require('guess-indent').setup()

require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
})

require('which-key').setup({
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  },
})

require('todo-comments').setup({ signs = false })

-- [[ mini.nvim collection ]]
-- mini.ai:       va) / yinq / ci' — better Around/Inside textobjects
-- mini.surround: saiw) / sd' / sr)' — add/delete/replace surrounding brackets/quotes
-- mini.statusline: simple statusline (replace with lualine etc. if desired)
require('mini.ai').setup({ n_lines = 500 })
require('mini.surround').setup()
local statusline = require('mini.statusline')
statusline.setup({ use_icons = vim.g.have_nerd_font })
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return '%2l:%-2v'
end

-- [[ Treesitter ]]
do
  local filetypes = {
    'bash', 'c', 'diff', 'html', 'lua', 'luadoc',
    'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
  }
  require('nvim-treesitter').install(filetypes)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetypes,
    callback = function()
      vim.treesitter.start()
    end,
  })
end

-- [[ Extension point ]]
-- Load any user-defined plugins from lua/custom/plugins/*.lua here, e.g.
--   pcall(require, 'custom.plugins')
-- See lua/custom/plugins/init.lua for the intended pattern.

-- vim: ts=2 sts=2 sw=2 et
