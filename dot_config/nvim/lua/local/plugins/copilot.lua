-- dot_config/nvim/lua/local/plugins/copilot.lua
-- Copilot - AI-powered code suggestions
-- GitHub Copilot integration for Neovim

return {
  "github/copilot.vim",
  config = function()
    vim.keymap.set("i", "<C-;>", 'copilot#accept("<CR>")', {
      expr = true,
      replace_keycodes = false,
    })

    vim.g.copilot_no_tab_map = true
    -- You can also use <C-]> to dismiss suggestions
    vim.keymap.set("i", "<C-]>", "<Plug>(copilot.dismiss)")
  end,
}
