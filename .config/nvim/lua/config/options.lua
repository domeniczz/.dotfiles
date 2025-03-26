local g = vim.g

g.have_nerd_font = true

g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

--  For more options, you can see `:help option-list`

local opt = vim.opt

opt.termguicolors = true

-- opt.lazyredraw = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smarttab = true
opt.breakindent = true

opt.textwidth = 0

opt.relativenumber = true
opt.number = true
opt.numberwidth = 2

opt.hlsearch = true
opt.incsearch = true

-- Highlight current cursor line / column
-- Configured with autocmd instead
-- opt.cursorline = true
-- opt.cursorcolumn = true
-- opt.colorcolumn = "80"

opt.whichwrap = "<,>,[,]"

-- Configure system clipboard integration
-- https://neovim.io/doc/user/provider.html#clipboard-tool
-- For wayland, according to neovim doc, neovim looks for wl-clipboard (wl-copy, wl-paste)
-- Check if it's present with `:checkhealth provider.clipboard`
-- If wl-clipboard is not present, install it first
-- opt.clipboard = 'unnamedplus'

opt.mouse = "a"
opt.mousescroll = "ver:3,hor:6"

opt.showmode = true

opt.synmaxcol = 300

opt.wrap = true
opt.linebreak = true

opt.autoindent = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true

opt.foldlevel = 30
opt.foldcolumn = "1"
-- Set in treesitter plugin config instead, to make sure it's set after loading treesitter plugin
-- opt.foldmethod = 'expr'
-- opt.foldexpr = 'nvim_treesitter#foldexpr()'

opt.scrolloff = 10
opt.sidescrolloff = 8
opt.smoothscroll = true

opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
opt.undofile = true

opt.updatetime = 5000
opt.ttimeoutlen = 20
opt.timeoutlen = 500

opt.signcolumn = "yes"

opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.fileformats = "unix,dos,mac"
opt.autoread = true
opt.hidden = true -- Allow switching buffers without saving
opt.fillchars = { eob = " " }
opt.inccommand = "nosplit"
opt.showcmd = false
opt.cmdheight = 1
opt.laststatus = 3
opt.shell = "zsh"
opt.path:append({ "**" }) -- search file into subdirectories
opt.wildmenu = on
opt.wildignore:append({ "*/node_modules/*" })
