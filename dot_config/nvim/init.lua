-- dot_config/nvim/init.lua
-- NeoVim entry point - initializes NvChad framework with custom configuration

-- Set leader key early
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim if needed
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Load NvChad options and autocommands
require 'nvchad.options'
require 'nvchad.autocmds'

-- Load lazy.nvim with NvChad plugins
require 'nvchad.plugins'

-- Load custom settings (vim options from kickstart)
require 'custom.settings'

-- Load NvChad mappings
require 'nvchad.mappings'

-- Load custom mappings and LSP setup
require 'custom.init'
