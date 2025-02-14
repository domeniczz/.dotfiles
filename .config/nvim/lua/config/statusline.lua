-- ----------------------------------------------------------------------------
-- Git status
-- ----------------------------------------------------------------------------

_G.git_file_status_cache = {}

_G.git_file_status = {
  ["?"] = "untracked",
  ["??"] = "untracked",
  ["!"] = "ignored",
  ["!!"] = "ignored",
  ["A"] = "added",
  ["D"] = "deleted",
  ["R"] = "renamed",
  ["C"] = "copied",
  ["U"] = "unmerged",
  ["M"] = "modified",
  ["T"] = "type changed",
  ["AM"] = "added modified",
  ["MM"] = "modified",
  ["MD"] = "modified deleted",
  ["DD"] = "both deleted",
  ["AA"] = "both added",
  ["UU"] = "both modified",
  ["AU"] = "added by us",
  ["UA"] = "added by them",
  ["UD"] = "deleted by them",
  ["DU"] = "deleted by us",
}

function _G.get_git_root(file_path)
  local git_cmd = string.format(
    "git -C %s rev-parse --show-toplevel 2>/dev/null",
    vim.fn.shellescape(vim.fn.fnamemodify(file_path, ":h"))
  )
  local git_root = vim.fn.system(git_cmd):gsub("[\n\r]", "")
  return vim.v.shell_error == 0 and git_root or nil
end

function _G.update_git_file_status_cache()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" or vim.bo.buftype ~= "" then
    _G.git_file_status_cache[bufname] = ""
    return ""
  end
  local resolved_file_path = vim.fn.resolve(bufname)
  local git_root = _G.get_git_root(resolved_file_path)
  if not git_root then
    _G.git_file_status_cache[bufname] = ""
    return ""
  end
  local abs_git_root_path = vim.fn.fnamemodify(git_root, ":p"):gsub("/$", "")
  local abs_file_path = vim.fn.fnamemodify(resolved_file_path, ":p"):gsub("/$", "")
  local relative_file_path
  if vim.startswith(abs_file_path, abs_git_root_path .. "/") then
    relative_file_path = abs_file_path:sub(#abs_git_root_path + 2)
  else
    relative_file_path = vim.fn.fnamemodify(resolved_file_path, ":t")
  end
  local git_cmd = string.format(
    "git -C %s status --porcelain=v1 %s 2>/dev/null",
    vim.fn.shellescape(git_root),
    vim.fn.shellescape(relative_file_path)
  )
  local git_status_output = vim.fn.system(git_cmd):gsub("[\n\r]", "")
  local icon, status_text
  if git_status_output == "" then
    icon = _G.icons.git.clean
    status_text = "unmodified"
  else
    icon = _G.icons.git.dirty
    local status_code = git_status_output:sub(1, 2):gsub("[%s%.]", ""):sub(1, 2)
    status_text = _G.git_file_status[status_code] or "unknown"
  end
  local status = "[" .. icon .. " " .. status_text .. "]"
  _G.git_file_status_cache[bufname] = status
  return status
end

function _G.refresh_git_status()
  if vim.api.nvim_buf_is_valid(vim.api.nvim_get_current_buf()) then
    _G.update_git_file_status_cache()
  end
end

function _G.should_show_git_status()
  return vim.bo.buftype == "" and vim.bo.filetype ~= "netrw"
end

local nvim_startup_done = false

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    nvim_startup_done = true
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
  callback = function()
    if nvim_startup_done and _G.should_show_git_status() then
      _G.refresh_git_status()
    end
  end,
})

function _G.git_status()
  if not _G.should_show_git_status() then
    return ""
  end
  local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  return _G.git_file_status_cache[bufname] or _G.update_git_file_status_cache()
end

-- ----------------------------------------------------------------------------
-- LSP diagnostic
-- ----------------------------------------------------------------------------

_G.lsp_diagnostic_cache = ""

function _G.update_lsp_diagnostic_cache()
  if #vim.diagnostic.count(0) == 0 then
    _G.lsp_diagnostic_cache = ""
    return
  end
  local errors = #vim.diagnostic.count(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.count(0, { severity = vim.diagnostic.severity.WARN })
  local infos = #vim.diagnostic.count(0, { severity = vim.diagnostic.severity.INFO })
  -- local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
  local parts = {}
  local icon = icons.lsp_diagnostic
  if errors > 0 then
    table.insert(parts, "%#StatusLineDiagnosticError#" .. icon.error .. " " .. errors)
  end
  if warnings > 0 then
    table.insert(parts, "%#StatusLineDiagnosticWarn#" .. icon.warn .. " " .. warnings)
  end
  if infos > 0 then
    table.insert(parts, "%#StatusLineDiagnosticHint#" .. icon.info .. " " .. infos)
  end
  -- if hints > 0 then
  --   table.insert(parts, "%#StatusLineDiagnosticInfo#" .. icons.hint .. " " .. hints)
  -- end
  _G.lsp_diagnostic_cache = "%*[" .. table.concat(parts, " ") .. "%*]"
end

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LSPAttach", "BufEnter" }, {
  callback = function()
    _G.update_lsp_diagnostic_cache()
    vim.cmd("redrawstatus")
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local statusline_bg = vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg
    vim.api.nvim_set_hl(0, "StatusLineDiagnosticError", {
      fg = vim.api.nvim_get_hl(0, { name = "DiagnosticError" }).fg,
      bg = statusline_bg,
    })
    vim.api.nvim_set_hl(0, "StatusLineDiagnosticWarn", {
      fg = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn" }).fg,
      bg = statusline_bg,
    })
    vim.api.nvim_set_hl(0, "StatusLineDiagnosticInfo", {
      fg = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo" }).fg,
      bg = statusline_bg,
    })
    -- vim.api.nvim_set_hl(0, "StatusLineDiagnosticHint", {
    --   fg = vim.api.nvim_get_hl(0, { name = "DiagnosticHint" }).fg,
    --   bg = statusline_bg,
    -- })
  end,
})

function _G.lsp_diagnostic()
  return _G.lsp_diagnostic_cache
end

-- ----------------------------------------------------------------------------
-- LSP status
-- ----------------------------------------------------------------------------

_G.lsp_status_cache = {}

function _G.update_lsp_status_cache()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local icon = _G.icons.lsp
  local status
  if vim.bo.buftype ~= "" then return "" end
  local lang_icon = icon.language[vim.bo.filetype] or icon.language.default
  if #clients > 0 then
    status = "%*[" .. "%#StatusLineLspEnabled#" .. lang_icon .. " " .. icon.indicator.enabled .. "%*]"
  else
    status = "%*[" .. "%#StatusLineLspDisabled#" .. lang_icon .. " " .. icon.indicator.disabled .. "%*]"
  end
  _G.lsp_status_cache[vim.bo.filetype] = status
  return status
end

vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "BufEnter" }, {
  callback = function()
    if vim.bo.buftype == "" and _G.lsp_configured_lang[vim.bo.filetype] then
      _G.update_lsp_status_cache()
      vim.cmd("redrawstatus")
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local statusline_bg = vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg
    vim.api.nvim_set_hl(0, "StatusLineLspEnabled", {
      fg = vim.api.nvim_get_hl(0, { name = "DiagnosticOk" }).fg,
      bg = statusline_bg,
    })
  end,
})

function _G.lsp_status()
  return _G.lsp_status_cache[vim.bo.filetype] or ""
end

-- ----------------------------------------------------------------------------
-- Buffers
-- ----------------------------------------------------------------------------

function _G.buf_info()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local total = #bufs
  local cur_buf = vim.fn.bufnr()
  local index = 0
  for i, buf in ipairs(bufs) do
    if buf.bufnr == cur_buf then
      index = i
      break
    end
  end
  return index and string.format("[%d/%d]", index, total) or ""
end

-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------

_G.lazy_plugin_updates_count = 0

function _G.lazy_plugin_updates()
  local icon = _G.icons.plugin_update.available
  return _G.lazy_plugin_updates_count > 0 and string.format("[%s %d]", icon, _G.lazy_plugin_updates_count) or ""
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    _G.lazy_plugin_updates_count = require("lazy.status").updates() or 0
  end,
})

-- ----------------------------------------------------------------------------
-- StatusLine
-- ----------------------------------------------------------------------------

_G.statusline_components = {
  "%<",                                         -- Truncation point
  "%f",                                         -- File path
  " %m",                                        -- Modified flag
  "%r",                                         -- Readonly flag
  "%{%v:lua.git_status()%}",                    -- Git branch
  "%{%v:lua.lsp_status()%}",                    -- LSP status
  "%{%v:lua.lsp_diagnostic()%}",                -- LSP diagnostics
  "%=",                                         -- Left/right separator
  "%{%v:lua.lazy_plugin_updates()%}",
  " %{%v:lua.buf_info()%}",                      -- Buffer count
  " [%{&fileencoding?&fileencoding:&encoding}", -- File encoding
  " %{&fileformat}]",                           -- File format
  " %l:%c",                                     -- Line and column
  " %P",                                        -- Percentage through file
}

vim.opt.statusline = table.concat(_G.statusline_components, "")

-- ----------------------------------------------------------------------------
-- Constants
-- ----------------------------------------------------------------------------

_G.icons = vim.g.have_nerd_font and {
  git = {
    clean = "󰊢", dirty = "",
  },
  lsp_diagnostic = {
    error = "", warn = "", info = "", hint = "H",
  },
  lsp = {
    indicator = {
      enabled = "+",
      disabled = "-",
    },
    language = {
      lua = "󰢱",
      python = "󰌠",
      javascript = "",
      typescript = "󰛦",
      c = "󰙱",
      cpp = "󰙲",
      csharp = "󰌛",
      rust = "󱘗",
      ruby = "󰴭",
      go = "󰟓",
      java = "󰬷",
      kotlin = "󱈙",
      html = "󰌝",
      css = "󰌜",
      default = "󰈮",
    },
  },
  plugin_update = {
    available = "󰚰",
  },
} or {
  git = {
    clean = "C", dirty = "D",
  },
  lsp_diagnostic = {
    error = "E", warn = "W", info = "I", hint = "H",
  },
  lsp = {
    indicator = {
      enabled = "+",
      disabled = "-",
    },
    language = {
      default = "L",
    },
  },
  plugin_update = {
    available = "U",
  },
}

_G.lsp_configured_lang = {
  lua = true,
  python = true,
  rust = true,
}
