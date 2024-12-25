vim.g.have_nerd_font = true

-- Disable netrw (vim builtin file explorer)
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- [[ Setting options ]]
-- See `:help opt.
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

local opt = vim.opt

opt.termguicolors = true

opt.tabstop = 4 -- A TAB character looks like 4 spaces
opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
opt.shiftwidth = 4 -- Number of spaces inserted when indenting

opt.relativenumber = true
opt.number = true

opt.hlsearch = true
opt.incsearch = true

-- Highlight current cursor line / column
-- vim.opt.cursorline = true
-- vim.opt.cursorcolumn = true

-- Allow left and right arrow keys to move across lines in Insert mode
opt.whichwrap = '<,>,[,]'

-- Configure system clipboard integration
-- https://neovim.io/doc/user/provider.html#clipboard-tool
-- For wayland on linux, according to neovim doc, neovim looks for wl-clipboard (wl-copy, wl-paste)
-- Check if it is present with vim command :checkhealth provider.clipboard
-- If wl-clipboard is not present, install it first
-- opt.clipboard = 'unnamedplus'

-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
opt.showmode = true

-- Enable line wrapping
opt.wrap = true

opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

-- opt.colorcolumn = "80"

-- Highlight the screen column at the cursor position
-- opt.cursorcolumn = true

-- opt.swapfile = false
-- opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
-- Save undo history
opt.undofile = true

-- Decrease update time
opt.updatetime = 50

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 400
