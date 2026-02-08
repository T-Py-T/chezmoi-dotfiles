return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        file_ignore_patterns = {
          ".git",
          "node_modules",
          ".venv",
          "dist",
          "build",
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-l>"] = actions.preview_scrolling_down,
            ["<C-h>"] = actions.preview_scrolling_up,
          },
          n = {
            ["q"] = actions.close,
            ["<C-c>"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
        live_grep = {
          additional_args = function()
            return { "--hidden" }
          end,
        },
      },
    })

    telescope.load_extension("fzf")

    -- set keymaps
    local keymap = vim.keymap

    -- File finding
    keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor in cwd" })
    keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

    -- Telescope-specific pickers
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
    keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Telescope keymaps" })
    keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Telescope diagnostics" })
    keymap.set("n", "<leader>fw", builtin.lsp_workspace_symbols, { desc = "Telescope workspace symbols" })
    keymap.set("n", "<leader>fgc", builtin.git_commits, { desc = "Telescope git commits" })
    keymap.set("n", "<leader>fgs", builtin.git_status, { desc = "Telescope git status" })
    keymap.set("n", "<leader>fgb", builtin.git_branches, { desc = "Telescope git branches" })
  end,
}
