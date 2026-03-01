-- dot_config/nvim/lua/custom/chadrc.lua
-- NvChad configuration with custom keybindings from kickstart

local M = {}

-- Load custom mappings
M.mappings = require "custom.mappings"

-- Additional NvChad configs
M.ui = {
  theme = "catppuccin",
}

return M
