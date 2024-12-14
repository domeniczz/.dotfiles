local function augroup(name)
  return vim.api.nvim_create_augroup("nvim_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

-- Automatically update plugins with lazy
autocmd("VimEnter", {
  group = augroup("autoupdate"),
  callback = function()
    if require("lazy.status").has_updates then
      require("lazy").update({ show = false, })
    end
  end,
})

-- Hightlight yanked text
autocmd("TextYankPost", {
  group = augroup("highlightyank"),
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 300,
    })
  end,
})

-- Toggle to relative numbers when in normal mode and focused
number_toggle = augroup("numbertoggle")
autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
  group = number_toggle,
  callback = function()
    if vim.api.nvim_get_mode().mode ~= 'i' then
      vim.opt.relativenumber = true
    end
  end,
})

-- Toggle to absolute numbers when unfocused or in insert mode
autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
  group = number_toggle,
  callback = function()
    vim.opt.relativenumber = false
  end,
})

