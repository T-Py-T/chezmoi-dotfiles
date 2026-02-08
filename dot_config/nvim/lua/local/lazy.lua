-- dot_config/nvim/lua/local/lazy.lua
-- Lazy.nvim setup from ThePrimeagen
-- Bootstraps lazy.nvim and loads plugins from local.plugins

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = "local.plugins",
    change_detection = { notify = false }
})
