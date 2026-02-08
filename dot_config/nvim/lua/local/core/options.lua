-- Merged settings from ThePrimeagen's setup + our customizations

local opt = vim.opt

-- Line numbers (ThePrimeagen)
opt.guicursor = ""
opt.nu = true
opt.relativenumber = true

-- Tabs & indentation (ThePrimeagen: 4 spaces)
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- Smart indentation (ThePrimeagen)
opt.smartindent = true

-- Line wrapping (ThePrimeagen: disabled)
opt.wrap = false

-- Search settings (keep our custom settings alongside ThePrimeagen's)
opt.hlsearch = false -- ThePrimeagen
opt.incsearch = true -- ThePrimeagen
opt.ignorecase = true -- our addition
opt.smartcase = true -- our addition

-- Appearance (ThePrimeagen + ours)
opt.termguicolors = true -- ThePrimeagen
opt.background = "dark" -- our addition
opt.signcolumn = "yes" -- ThePrimeagen
opt.colorcolumn = "80" -- ThePrimeagen

-- Scrolling (ThePrimeagen)
opt.scrolloff = 8

-- Swap & backup (ThePrimeagen)
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- Cursor line (our addition)
opt.cursorline = true

-- Filename chars (ThePrimeagen)
opt.isfname:append("@-@")

-- Update time (ThePrimeagen)
opt.updatetime = 50

-- Backspace (our addition - good to keep)
opt.backspace = "indent,eol,start"

-- Clipboard (our addition - good to keep)
opt.clipboard:append("unnamedplus")

-- Split windows (our addition - good to keep)
opt.splitright = true
opt.splitbelow = true

-- Netrw settings (our addition - good for file navigation)
vim.cmd("let g:netrw_liststyle = 3")
