-- dot_config/nvim/lua/local/plugins/harpoon.lua
-- Harpoon - Quick file navigation with marks
-- Create persistent marks for frequently accessed files

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    local keymap = vim.keymap

    -- Add file to harpoon
    keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })

    -- Toggle harpoon menu
    keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon quick menu" })

    -- Navigate to harpoon file (1-9)
    for i = 1, 9 do
      keymap.set("n", string.format("<leader>h%d", i), function() harpoon:list():select(i) end, { desc = string.format("Harpoon file %d", i) })
    end

    -- Previous/next harpoon file
    keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon previous file" })
    keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon next file" })
  end,
}
