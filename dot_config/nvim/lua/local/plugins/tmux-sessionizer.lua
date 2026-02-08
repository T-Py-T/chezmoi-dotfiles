-- dot_config/nvim/lua/local/plugins/tmux-sessionizer.lua
-- Tmux Navigator - Seamless pane switching between tmux and vim
-- Allows C-h/C-j/C-k/C-l to navigate between vim and tmux panes

return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
    { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
  },
}

