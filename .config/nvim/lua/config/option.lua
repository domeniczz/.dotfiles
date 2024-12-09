-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Disable netrw (vim builtin file explorer)
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

vim.opt.termguicolors = true

-- Configure Tab behavior
vim.opt.tabstop = 4 -- A TAB character looks like 4 spaces
vim.opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.opt.shiftwidth = 4 -- Number of spaces inserted when indenting

-- Relative line numbering
vim.opt.relativenumber = true
vim.opt.number = true

local number_toggle = vim.api.nvim_create_augroup('numbertoggle', { clear = true })
-- Toggle to relative numbers when in normal mode and focused
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
  group = number_toggle,
  callback = function()
    if vim.api.nvim_get_mode().mode ~= 'i' then
      vim.opt.relativenumber = true
    end
  end,
})
-- Toggle to absolute numbers when unfocused or in insert mode
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
  group = number_toggle,
  callback = function()
    vim.opt.relativenumber = false
  end,
})

-- Allow left and right arrow keys to move across lines in Insert mode
vim.opt.whichwrap = '<,>,[,]'

-- Configure system clipboard integration
-- https://neovim.io/doc/user/provider.html#clipboard-tool
-- For wayland on linux, according to neovim doc, neovim looks for wl-clipboard (wl-copy, wl-paste)
-- Check if it is present with vim command :checkhealth provider.clipboard
-- If wl-clipboard is not present, install it first
vim.opt.clipboard = 'unnamedplus'

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = true

-- Enable line wrapping
vim.opt.wrap = true

vim.opt.smartindent = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- vim.opt.colorcolumn = "80"

-- vim.opt.swapfile = false
-- vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
-- Save undo history
vim.opt.undofile = true

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 400
