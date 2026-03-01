-- dot_config/nvim/lua/custom/mappings.lua
-- Custom keybindings from kickstart config adapted for NvChad
-- Merged with NvChad defaults to provide familiar workflow

local M = {}

M.general = {
  n = {
    -- Escape clears highlights
    ["<Esc>"] = { "<cmd>nohlsearch<CR>", "Clear highlight on escape" },

    -- Diagnostic mappings
    ["<leader>q"] = { vim.diagnostic.setloclist, "Open diagnostic quickfix" },

    -- Split navigation with Ctrl
    ["<C-h>"] = { "<C-w><C-h>", "Move focus to left window" },
    ["<C-l>"] = { "<C-w><C-l>", "Move focus to right window" },
    ["<C-j>"] = { "<C-w><C-j>", "Move focus to lower window" },
    ["<C-k>"] = { "<C-w><C-k>", "Move focus to upper window" },
  },

  t = {
    -- Terminal mode exit
    ["<Esc><Esc>"] = { "<C-\\><C-n>", "Exit terminal mode" },
  },
}

M.telescope = {
  n = {
    ["<leader>sh"] = { "<cmd>Telescope help_tags<CR>", "Search help" },
    ["<leader>sk"] = { "<cmd>Telescope keymaps<CR>", "Search keymaps" },
    ["<leader>sf"] = { "<cmd>Telescope find_files<CR>", "Search files" },
    ["<leader>ss"] = { "<cmd>Telescope builtin<CR>", "Search builtin commands" },
    ["<leader>sw"] = { "<cmd>Telescope grep_string<CR>", "Search word under cursor" },
    ["<leader>sg"] = { "<cmd>Telescope live_grep<CR>", "Search by grep" },
    ["<leader>sd"] = { "<cmd>Telescope diagnostics<CR>", "Search diagnostics" },
    ["<leader>sr"] = { "<cmd>Telescope resume<CR>", "Resume last telescope" },
  },
}

M.lsp = {
  n = {
    ["grn"] = { vim.lsp.buf.rename, "LSP Rename" },
    ["gra"] = { vim.lsp.buf.code_action, "LSP Code action" },
    ["grD"] = { vim.lsp.buf.declaration, "LSP Goto Declaration" },
    ["<leader>th"] = { 
      function() 
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 }) 
      end, 
      "Toggle inlay hints" 
    },
  },
}

return M
