-- dot_config/nvim/lua/local/plugins/tmux-sessionizer.lua
-- Tmux Sessionizer - Quick project switching
-- Like ThePrimeagen's tmux-sessionizer but integrated into Neovim

return {
  "ThePrimeagen/vim-tmux-navigator",
  config = function()
    -- This is automatically configured, but you can add custom settings here
    -- Keybindings are set by the plugin automatically:
    -- C-\ for tmux/vim pane switching
  end,
}
