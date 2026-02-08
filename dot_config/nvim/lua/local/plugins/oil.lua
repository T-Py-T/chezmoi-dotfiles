-- dot_config/nvim/lua/local/plugins/oil.lua
-- Oil - File explorer in a buffer (alternative to nvim-tree)
-- Better for quick navigation and file operations

return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      columns = {
        "icon",
        "size",
        "mtime",
      },
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      skip_confirm_for_simple_edits = false,
      prompt_save_on_select_new_file = true,
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, bufnr)
          return vim.startswith(name, ".")
        end,
      },
    })

    local keymap = vim.keymap
    keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open oil file explorer" })
    keymap.set("n", "<leader>-", "<cmd>Oil<cr>", { desc = "Open oil file explorer" })
  end,
}
