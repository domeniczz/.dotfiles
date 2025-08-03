local function augroup(name)
  return vim.api.nvim_create_augroup("_nvim_user_ac_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
  group = augroup("highlight_yanked_text"),
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 200,
    })
  end,
})

local number_toggle = augroup("relativenumber_toggle")
autocmd({ "VimEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = number_toggle,
  callback = function()
    if vim.api.nvim_get_mode().mode ~= "i" then vim.opt.relativenumber = true end
  end,
})
autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = number_toggle,
  callback = function()
    vim.opt.relativenumber = false
  end,
})

local cursorline_toggle = augroup("cursorline_toggle")
autocmd({ "VimEnter", "WinEnter", "BufWinEnter", "FocusGained" }, {
  group = cursorline_toggle,
  callback = function()
    vim.opt_local.cursorline = true
    -- vim.opt_local.cursorcolumn = true
  end,
})
autocmd({ "WinLeave", "FocusLost" }, {
  group = cursorline_toggle,
  callback = function()
    vim.opt_local.cursorline = false
    -- vim.opt_local.cursorcolumn = false
  end,
})

autocmd("FileType", {
  group = augroup("code_filetype_specific_tab_config"),
  pattern = { "lua", "yaml", "json", "vim" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

autocmd("FileType", {
  group = augroup("text_filetype_specific_config"),
  pattern = { "text", "markdown", "org", "gitcommit" },
  callback = function()
    vim.opt_local.list = true
    vim.opt_local.listchars:append({ eol = "↲" })
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us,en_gb"
  end,
})

autocmd("BufWritePre", {
  group = augroup("trim_trailing_empty_lines"),
  callback = function()
    local max_lines = 10000
    if vim.api.nvim_buf_line_count(0) > max_lines then
      vim.notify(
        string.format("Total lines more than threshold (%d), skipping whitespace cleanup for performance", max_lines),
        vim.log.levels.WARN,
        { title = "Whitespace Cleanup" }
      )
      return
    end
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local saved_search = vim.fn.getreg("/")
    if vim.bo.filetype ~= "markdown" then vim.cmd([[keeppatterns %s/\s\+$//e]]) end
    vim.cmd([[keeppatterns %s/\($\n\s*\)\+\%$//e]])
    vim.fn.setreg("/", saved_search)
    local last_line = vim.api.nvim_buf_line_count(0)
    local new_line = math.min(cursor_pos[1], last_line)
    vim.api.nvim_win_set_cursor(0, { new_line, cursor_pos[2] })
  end,
})

autocmd("BufReadPre", {
  group = augroup("largefile_performance_tweaks"),
  callback = function()
    if require("config.utils").is_current_large_file(vim.g.max_filesize) then
      local opt_local = vim.opt_local
      opt_local.spell = false
      opt_local.undofile = false
      opt_local.swapfile = false
      opt_local.foldmethod = "manual"
      opt_local.syntax = ""
      opt_local.colorcolumn = ""
      opt_local.conceallevel = 0
    end
  end,
})

autocmd("VimEnter", {
  group = augroup("statusline"),
  callback = function()
    require("config.statusline").setup()
  end,
})
