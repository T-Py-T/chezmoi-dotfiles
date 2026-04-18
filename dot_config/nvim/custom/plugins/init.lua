-- lua/custom/plugins/init.lua
-- Extension point for personal additions on top of the base kickstart+vim.pack config.
--
-- NOT auto-loaded. To use: uncomment `pcall(require, 'custom.plugins')` near
-- the bottom of init.lua, or add a direct `require('custom.plugins')` call.
--
-- With vim.pack, new plugins are simplest to add directly to the vim.pack.add({...})
-- list in init.lua. Use this file when you want to keep larger config blocks
-- out of init.lua (e.g. a debug setup, a separate statusline, project-specific
-- keymaps).
--
-- This file intentionally returns nothing — populate as needed.

return {}
