-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

if vim.opt.wrap:get() then
  map("n", "<Up>", "gk", { noremap = true, silent = true })
  map("n", "<Down>", "gj", { noremap = true, silent = true })
  map("i", "<Up>", "<C-o>gk", { noremap = true, silent = true })
  map("i", "<Down>", "<C-o>gj", { noremap = true, silent = true })
end

map({ 'n', "i", "v", "x" }, '<Up>', '<Nop>', { noremap = true, silent = true })
map({ 'n', "i", "v", "x" }, '<Down>', '<Nop>', { noremap = true, silent = true })
map({ 'n', "i", "v", "x" }, '<Left>', '<Nop>', { noremap = true, silent = true })
map({ 'n', "i", "v", "x" }, '<Right>', '<Nop>', { noremap = true, silent = true })

-- Open vim file explorer newrw
-- map("n", "<leader>pv", vim.cmd.Ex, { noremap = true, silent = true })

-- Move highlighted text up/down
map("v", "K", ":move '<-2<CR>gv=gv", { noremap = true, silent = true })
map("v", "J", ":move '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Keep cursor in place while joining lines with j
map("n", "J", "mzJ`z", { noremap = true, silent = true })

-- Scroll one page up/down while keeping cursor in the middle
map("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
map("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- Keep cursor in the middle while navigating through search results
map("n", "n", "nzzzv", { noremap = true, silent = true })
map("n", "N", "Nzzzv", { noremap = true, silent = true })

-- Stop setting `vim.opt.clipboard` to sync every fucking item in vim yanks with system clipboard
-- Normal yank won't sync to system clipboard
-- Sync to system clipboard
map({ "n", "v" }, "<leader>y", [["+y]], { noremap = true, silent = true })
map({ "n", "v" }, "<leader>Y", [["+Y]], { noremap = true, silent = true })

-- Paste from system clipboard
map({ "n", "v" }, "<leader>p", [["+p]], { noremap = true, silent = true })
map({ "n", "v" }, "<leader>P", [["+P]], { noremap = true, silent = true })

-- Paste over without loosing the paste register
map("x", "p", [["_dP]], { noremap = true, silent = true })

-- Delete into black hole register
map({ "n", "v" }, "<leader>d", [["_d]], { noremap = true, silent = true })

-- Change original vim "x" action, delete to black hole register
map({ "n", "v" }, "x", [["_x]], { noremap = true, silent = true })

-- Quickfix list navigation
map("n", "<C-k>", "<CMD>cnext<CR>zz", { noremap = true, silent = true })
map("n", "<C-j>", "<CMD>cprev<CR>zz", { noremap = true, silent = true })
map("n", "<leader>k", "<CMD>lnext<CR>zz", { noremap = true, silent = true })
map("n", "<leader>j", "<CMD>lprev<CR>zz", { noremap = true, silent = true })

-- Start %s replace the word cursor is currently on
map("n", "<leader>s", [[:%s/<C-r><C-w>/<C-r><C-w>/gIc<Left><Left><Left><Left>]], { noremap = true })
map("v", "<leader>s", [[:s///gIc<Left><Left><Left><Left><Left>]], { noremap = true })

-- Make current file executable
map("n", "<leader>x", "<CMD>!chmod +x %<CR>", { silent = true }, { noremap = true, silent = true })

-- Yank the whole file
map({ "n", "v" }, "<leader>[", "<CMD>%y+<CR>", { noremap = true, silent = true })

-- Create a vertical split window
map("n", "<leader>vs", "<CMD>vertical split<CR>", { noremap = true, silent = true })
-- Create a verOpentical split new window
map("n", "<leader>vn", "<CMD>vertical new<CR>", { noremap = true, silent = true })

map("n", "<leader>ls", "<CMD>LspStart<CR>", { noremap = true, silent = true })
map("n", "<leader>lx", "<CMD>LspStop<CR>", { noremap = true, silent = true })

map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal insert mode", noremap = true, silent = true })
map("n", "<leader>`", function()
  local win_height = vim.api.nvim_win_get_height(0)
  local terminal_height = math.floor(win_height * 0.22)
  terminal_height = math.max(5, math.min(terminal_height, 35))
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, terminal_height)
  vim.cmd("startinsert")
end, { desc = "Open a small terminal at bottom", noremap = true, silent = true })

map("n", "Q", require('config.utils').kill_buffer_or_close_window, { noremap = true, silent = true })
