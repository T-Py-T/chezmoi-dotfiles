-- dot_config/nvim/lua/custom/init.lua
-- Custom initialization - integrates kickstart config with NvChad
-- This file loads after NvChad base initialization

-- Load custom settings (vim options)
require "custom.settings"

-- Load custom mappings
local mappings = require "custom.mappings"

-- Apply general mappings
if mappings.general then
  for mode, maps in pairs(mappings.general) do
    for keybind, action in pairs(maps) do
      vim.keymap.set(mode, keybind, action[1], { desc = action[2], noremap = true })
    end
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

-- Apply LSP mappings (loaded dynamically when LSP attaches)
if mappings.lsp then
  local augroup = vim.api.nvim_create_augroup("custom_lsp_mappings", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function()
      for keybind, action in pairs(mappings.lsp.n or {}) do
        local opts = { desc = action[2], noremap = true }
        if type(action[1]) == "function" then
          vim.keymap.set("n", keybind, action[1], opts)
        else
          vim.keymap.set("n", keybind, action[1], opts)
        end
      end
    end,
  })
end

-- Setup terminal mode mapping
if mappings.general and mappings.general.t then
  for keybind, action in pairs(mappings.general.t) do
    vim.keymap.set("t", keybind, action[1], { desc = action[2], noremap = true })
  end
end
