-- dot_config/nvim/lua/custom/chadrc.lua
-- NvChad configuration with integrated kickstart customizations

local M = {}

-- Import kickstart settings (vim.o, vim.opt options, etc.)
-- This file extracts and applies the key settings from kickstart
require "custom.settings"

-- Load custom mappings
M.mappings = require "custom.mappings"

-- UI Configuration
M.ui = {
  theme = "catppuccin",
}

return M
