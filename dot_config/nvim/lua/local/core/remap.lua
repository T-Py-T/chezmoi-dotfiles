-- dot_config/nvim/lua/local/core/remap.lua
-- Merged keybindings from ThePrimeagen + our custom keybindings
-- Source: https://github.com/ThePrimeagen/neovimrc/blob/master/lua/theprimeagen/remap.lua

vim.g.mapleader = " "

local keymap = vim.keymap

-- ==================== ThePrimeagen's Core Keymaps ====================

-- Ex command (file browser)
keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file browser" })

-- Move lines in visual mode (ThePrimeagen)
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Keep cursor centered (ThePrimeagen)
keymap.set("n", "J", "mzJ`z", { desc = "Join lines centered" })
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page down centered" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page up centered" })
keymap.set("n", "n", "nzzzv", { desc = "Next search centered" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search centered" })

-- Greatest remap ever - paste without overwriting register (ThePrimeagen)
keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without register" })

-- Next greatest remap ever - copy to system clipboard (ThePrimeagen)
keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

-- Delete to void register (ThePrimeagen)
keymap.set({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete to void" })

-- Escape remaps (ThePrimeagen)
-- keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape with C-c" })

-- Disable Q (ThePrimeagen)
keymap.set("n", "Q", "<nop>", { desc = "Disable Q" })

-- Format buffer (ThePrimeagen LSP)
-- keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format buffer" })

-- Quickfix navigation (ThePrimeagen)
keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix" })
keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location" })
keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous location" })

-- Find and replace word under cursor (ThePrimeagen)
keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Find/replace word" })

-- Make file executable (ThePrimeagen)
keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make executable" })

-- Go error handling snippet (ThePrimeagen)
keymap.set("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", { desc = "Go error handle" })

-- Reload config (ThePrimeagen)
keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end, { desc = "Reload config" })

-- ==================== Our Custom Keymaps (Preserved) ====================

-- General keymaps from our original setup
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
-- keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- Conflicts with split, commented out

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- ==================== Plugin-specific keymaps ====================
-- Harpoon keymaps are set in harpoon.lua plugin
-- Telescope keymaps are set in telescope.lua plugin
-- Trouble keymaps are set in trouble.lua plugin
-- Oil keymaps are set in oil.lua plugin
-- LSP keymaps are set in init.lua (LspAttach)
