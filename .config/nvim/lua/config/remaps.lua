-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- When line wrapping is enabled
if vim.opt.wrap:get() then
  map("n", "<Up>", "gk", { noremap = true, silent = true })
  map("n", "<Down>", "gj", { noremap = true, silent = true })
  map("i", "<Up>", "<C-o>gk", { noremap = true, silent = true })
  map("i", "<Down>", "<C-o>gj", { noremap = true, silent = true })
end

map({ "n", "i", "v", "x" }, "<Up>", "<Nop>", { noremap = true, silent = true })
map({ "n", "i", "v", "x" }, "<Down>", "<Nop>", { noremap = true, silent = true })
map({ "n", "i", "v", "x" }, "<Left>", "<Nop>", { noremap = true, silent = true })
map({ "n", "i", "v", "x" }, "<Right>", "<Nop>", { noremap = true, silent = true })

-- Open vim file explorer newrw
-- map("n", "<leader>pv", vim.cmd.Ex, { noremap = true, silent = true })

-- Navigate thorugh items in quickfix list
map("n", "<M-j>", "<CMD>cnext<CR>", { noremap = true, silent = true })
map("n", "<M-k>", "<CMD>cprev<CR>", { noremap = true, silent = true })

-- Navigate thorugh buffers in buffer list
map("n", "<M-h>", "<CMD>bprevious<CR>", { noremap = true, silent = true })
map("n", "<M-l>", "<CMD>bnext<CR>", { noremap = true, silent = true })

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

-- Stop setting `vim.opt.clipboard` to sync every item vim yanks to system clipboard
-- Yank to system clipboard
map({ "n", "v" }, "<leader>y", [["+y]], { noremap = true, silent = true })
map({ "n", "v" }, "<leader>Y", [["+Y]], { noremap = true, silent = true })

-- Paste from system clipboard
map({ "n", "v" }, "<leader>p", [["+p]], { noremap = true, silent = true })
map({ "n", "v" }, "<leader>P", [["+P]], { noremap = true, silent = true })

-- Paste over without loosing the paste register
map("x", "p", [["_dP]], { noremap = true, silent = true })

map("n", "Y", "y$", { noremap = true, silent = true })

-- Delete into black hole register
map({ "n", "v" }, "<leader>d", [["_d]], { noremap = true, silent = true })

-- Quickfix list navigation
map("n", "<C-k>", "<CMD>cnext<CR>zz", { noremap = true, silent = true })
map("n", "<C-j>", "<CMD>cprev<CR>zz", { noremap = true, silent = true })
map("n", "<leader>k", "<CMD>lnext<CR>zz", { noremap = true, silent = true })
map("n", "<leader>j", "<CMD>lprev<CR>zz", { noremap = true, silent = true })

-- Start %s replace the word cursor is currently on
map("n", "<C-s>", [[:%s/<C-r><C-w>/<C-r><C-w>/gIc<Left><Left><Left><Left>]], { noremap = true })
map("v", "<C-s>", [[:s///gIc<Left><Left><Left><Left><Left>]], { noremap = true })

-- Make current file executable
map("n", "<leader>x", "<CMD>!chmod +x %<CR>", { noremap = true, silent = true })

-- Yank the whole file
map({ "n", "v" }, "<leader>[", "<CMD>%y+<CR>", { noremap = true, silent = true })

map("n", "<leader>vs", "<CMD>vertical split<CR>", { noremap = true, silent = true })
map("n", "<leader>vn", "<CMD>vertical new<CR>", { noremap = true, silent = true })

map("n", "<leader>ls", "<CMD>LspStart<CR>", { noremap = true, silent = true })
map("n", "<leader>lx", "<CMD>LspStop<CR>", { noremap = true, silent = true })
map("n", "<leader>vrr", vim.lsp.buf.references, { noremap = true, silent = true })
map("n", "<leader>vrn", vim.lsp.buf.rename, { noremap = true, silent = true })

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

map("n", "<leader>tt", require("config.utils").toggle_floating_terminal, { noremap = true, silent = true })
map("n", "<leader>o", "<CMD>only<CR>", { noremap = true, silent = true })
map("n", "Q", function()
  require("config.utils").smart_buffer_close({
    quit_on_empty = vim.g.quit_on_empty ~= false,
    prune_extra_wins = true
  })
end, { desc = "Delete buffer smartly", noremap = true, silent = true })
