-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Open vim file explorer newrw
-- map("n", "<leader>pv", vim.cmd.Ex)

-- Move highlighted text up/down
map("v", "K", ":move '<-2<CR>gv=gv")
map("v", "J", ":move '>+1<CR>gv=gv")

-- Keep cursor in place while joining lines with j
map("n", "J", "mzJ`z")

-- Scroll one page up/down while keeping cursor in the middle
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Keep cursor in the middle while navigating through search results
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

if vim.opt.wrap:get() then
  map("n", "<Up>", "gk")
  map("n", "<Down>", "gj")
  map("i", "<Up>", "<C-o>gk")
  map("i", "<Down>", "<C-o>gj")
end

-- Stop setting `vim.opt.clipboard` to sync every fucking item in vim yanks with system clipboard
-- Normal yank won't sync to system clipboard
-- Sync to system clipboard
map({ "n", "v" }, "<leader>y", [["+y]])
map({ "n", "v" }, "<leader>Y", [["+Y]])

-- Paste from system clipboard
map({ "n", "v" }, "<leader>p", [["+p]])
map({ "n", "v" }, "<leader>P", [["+P]])

-- Paste over without loosing the paste register
map("x", "p", [["_dP]])

-- Delete into black hole register
map({ "n", "v" }, "<leader>d", [["_d]])

-- Change original vim "x" action, delete to black hole register
map({ "n", "v" }, "x", [["_x]])

map("i", "<C-z>", "<Esc>ui")

map("n", "<C-f>", "<CMD>silent !tmux neww tmux-sessionizer<CR>")

-- Quickfix list navigation
map("n", "<C-k>", "<CMD>cnext<CR>zz")
map("n", "<C-j>", "<CMD>cprev<CR>zz")
map("n", "<leader>k", "<CMD>lnext<CR>zz")
map("n", "<leader>j", "<CMD>lprev<CR>zz")

-- Start %s replace the word cursor is currently on
map("n", "<leader>s", [[:%s/<C-r><C-w>/<C-r><C-w>/gIc<Left><Left><Left><Left>]])
map("v", "<leader>s", [[:s///gIc<Left><Left><Left><Left><Left>]])

-- Make current file executable
map("n", "<leader>x", "<CMD>!chmod +x %<CR>", { silent = true })

-- Yank the whole file
map({ "n", "v" }, "<leader>[", "<CMD>%y+<CR>")

-- Create a vertical split window
map("n", "<leader>vs", "<CMD>vertical split<CR>")
-- Create a verOpentical split new window
map("n", "<leader>vn", "<CMD>vertical new<CR>")

map("n", "<leader>ls", "<CMD>LspStart<CR>")
map("n", "<leader>lx", "<CMD>LspStop<CR>")

map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal insert mode" })
map("n", "<leader>`", function()
  local win_height = vim.api.nvim_win_get_height(0)
  local terminal_height = math.floor(win_height * 0.22)
  terminal_height = math.max(5, math.min(terminal_height, 35))
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, terminal_height)
  vim.cmd("startinsert")
end, { desc = "Open a small terminal at bottom" })

map("n", "Q", require('config.utils').kill_buffer_or_close_window, { silent = true })
