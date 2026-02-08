-- dot_config/nvim/lua/local/plugins/spectre.lua
-- Spectre - Find and replace interface
-- Better than grep for find and replace operations

return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local keymap = vim.keymap

    keymap.set("n", "<leader>ss", "<cmd>Spectre<cr>", { desc = "Spectre find and replace" })
    keymap.set("n", "<leader>sw", "<cmd>Spectre<cr>", { desc = "Spectre find and replace word" })
  end,
}
