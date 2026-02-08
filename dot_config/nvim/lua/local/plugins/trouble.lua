-- dot_config/nvim/lua/local/plugins/trouble.lua
-- Trouble - Better diagnostics list and quickfix list
-- Shows errors, warnings, and other LSP diagnostics in a nice panel

return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local trouble = require("trouble")
    trouble.setup({
      position = "bottom",
      height = 10,
      width = 50,
      icons = true,
      mode = "document_diagnostics",
      severity = nil,
      fold_open = "",
      fold_closed = "",
      indent_lines = true,
      multiline = true,
      win_config = { border = "rounded" },
      auto_open = false,
      auto_close = false,
      auto_preview = true,
      auto_jump = false,
      include_declaration = { "lsp_references", "lsp_implementations", "lsp_definitions" },
      signs = {
        error = "",
        warning = "",
        hint = "",
        information = "",
        other = "﫠",
      },
      use_diagnostic_signs = false,
    })

    local keymap = vim.keymap
    keymap.set("n", "<leader>xx", "<cmd>Trouble toggle<cr>", { desc = "Toggle trouble list" })
    keymap.set("n", "<leader>xw", "<cmd>Trouble toggle workspace_diagnostics<cr>", { desc = "Workspace diagnostics" })
    keymap.set("n", "<leader>xd", "<cmd>Trouble toggle document_diagnostics<cr>", { desc = "Document diagnostics" })
    keymap.set("n", "<leader>xq", "<cmd>Trouble toggle quickfix<cr>", { desc = "Quickfix list" })
    keymap.set("n", "<leader>xl", "<cmd>Trouble toggle loclist<cr>", { desc = "Location list" })
    keymap.set("n", "gR", "<cmd>Trouble toggle lsp_references<cr>", { desc = "LSP references" })
  end,
}
