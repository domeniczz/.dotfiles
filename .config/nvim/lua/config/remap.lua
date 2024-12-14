-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap

-- Map space+pv to vim command :Ex
-- keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move highlighted text up/down
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor in place while joining lines with j
keymap.set("n", "J", "mzJ`z")

-- Ctrl-u/Ctrl-d to scroll one page up/down while keeping cursor in the middle
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep cursor in the middle while navigating through search results
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

keymap.set("x", "<leader>p", [["_dP]])

-- Stop setting `vim.opt.clipboard` to sync every fucking item in vim yanks with system clipboard
-- Normal yank won't sync to system clipboard
-- <leader> + yank, sync to system clipboard
keymap.set({"n", "v"}, "<leader>y", [["+y]])
keymap.set({"n", "v"}, "<leader>Y", [["+Y]])

-- <leader> + paste, paste from system clipboard
keymap.set({"n", "v"}, "<leader>p", [["+p]])
keymap.set({"n", "v"}, "<leader>P", [["+P]])

-- <leader> + d, delete into black hole register
keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- Change original vim "x" action, delete to black hole register
keymap.set({"n", "v"}, "x", [["_x]])

-- keymap.set("n", "Q", "<nop>")

keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Quickfix list navigation
keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- <leader> + s to start replace the word cursor is currently on
keymap.set("n", "<leader>s", [[:%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>]])

-- <leader> + x to make the current file executable
keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

