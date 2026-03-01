-- dot_config/nvim/lua/custom/init.lua
-- Custom initialization for NvChad with kickstart keybindings

-- Load our custom mappings
local mappings = require "custom.mappings"

-- Apply general mappings
for mode, maps in pairs(mappings.general) do
  for keybind, action in pairs(maps) do
    vim.keymap.set(mode, keybind, action[1], { desc = action[2], noremap = true })
  end
end

-- Apply telescope mappings
if mappings.telescope then
  for mode, maps in pairs(mappings.telescope) do
    for keybind, action in pairs(maps) do
      vim.keymap.set(mode, keybind, action[1], { desc = action[2], noremap = true })
    end
  end
end

-- Apply LSP mappings
if mappings.lsp then
  for mode, maps in pairs(mappings.lsp) do
    for keybind, action in pairs(maps) do
      local opts = { desc = action[2], noremap = true }
      if type(action[1]) == "function" then
        vim.keymap.set(mode, keybind, action[1], opts)
      else
        vim.keymap.set(mode, keybind, action[1], opts)
      end
    end
  end
end
