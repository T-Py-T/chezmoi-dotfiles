-- dot_config/nvim/lua/custom/settings.lua
-- Custom NeoVim settings extracted from kickstart configuration
-- This file applies all the vim.o and vim.opt configurations from kickstart

-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = false

-- [[ Core Settings ]]
vim.o.number = true
-- vim.o.relativenumber = true  -- Uncomment for relative line numbers

-- Enable mouse mode
vim.o.mouse = 'a'

-- Don't show the mode (status line handles it)
vim.o.showmode = false

-- Sync clipboard with OS
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive search unless \C or capital letters
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure splits
vim.o.splitright = true
vim.o.splitbelow = true

-- Display whitespace characters
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live
vim.o.inccommand = 'split'

-- Configure indentation
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Minimal number of screen lines to keep above/below cursor
vim.o.scrolloff = 10
vim.o.sidescrolloff = 10
