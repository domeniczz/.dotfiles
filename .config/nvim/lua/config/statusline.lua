-- ----------------------------------------------------------------------------
-- Constants
-- ----------------------------------------------------------------------------

local icons = vim.g.have_nerd_font and {
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
  plugin_updates = "󰚰",
  buffers = "",
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
  plugin_updates = "U",
  buffers = "B",
}

local lsp_configured_lang = {
  lua = true,
  python = true,
  rust = true,
}

-- ----------------------------------------------------------------------------
-- Git status
-- ----------------------------------------------------------------------------

local git_file_status_cache = {}

local git_file_status = {
  ["?"] = "untracked",
  ["??"] = "untracked",
  ["!"] = "ignored",
  ["!!"] = "ignored",
  ["A"] = "added",
  ["D"] = "deleted",
  ["R"] = "renamed",
  ["C"] = "copied",
  ["U"] = "unmerged",
  [" M"] = "modified",
  ["M"] = "added",
  ["T"] = "type changed",
  ["AM"] = "added modified",
  ["MM"] = "added modified",
  ["MD"] = "modified deleted",
  ["DD"] = "both deleted",
  ["AA"] = "both added",
  ["UU"] = "both modified",
  ["AU"] = "added by us",
  ["UA"] = "added by them",
  ["UD"] = "deleted by them",
  ["DU"] = "deleted by us",
}

function get_git_root(file_path)
  local git_cmd = { "git", "-C", vim.fn.fnamemodify(file_path, ":h"), "rev-parse", "--show-toplevel" }
  local git_root = vim.fn.systemlist(git_cmd)[1]
  return vim.v.shell_error == 0 and git_root or nil
end

function _G.update_git_file_status_cache()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" or vim.bo.buftype ~= "" then
    git_file_status_cache[bufname] = ""
    return ""
  end
  local resolved_file_path = vim.fn.resolve(bufname)
  local git_root = get_git_root(resolved_file_path)
  if not git_root then
    git_file_status_cache[bufname] = ""
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
  local git_cmd = { "git", "-C", git_root, "status", "--porcelain=v1", relative_file_path }
  local git_status = vim.fn.system(git_cmd):gsub("[\n\r]", "")
  local icon, status_text
  if git_status == "" then
    icon = icons.git.clean
    status_text = "unmodified"
  else
    icon = icons.git.dirty
    local status_code = git_status:sub(1, 2):gsub("%s$", ""):sub(1, 2)
    status_text = git_file_status[status_code] or "unknown"
  end
  local status = "[" .. icon .. " " .. status_text .. "]"
  git_file_status_cache[bufname] = status
  return status
end

local function should_show_git_status()
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
    if nvim_startup_done and should_show_git_status() then
      update_git_file_status_cache()
    end
  end,
})

function _G.git_status()
  if not should_show_git_status() then
    return ""
  end
  local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  return git_file_status_cache[bufname] or update_git_file_status_cache()
end

-- ----------------------------------------------------------------------------
-- LSP diagnostic
-- ----------------------------------------------------------------------------

local lsp_diagnostic_cache = ""

local function update_lsp_diagnostic_cache()
  if #vim.diagnostic.count(0) == 0 then
    lsp_diagnostic_cache = ""
    return
  end
  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
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
  lsp_diagnostic_cache = "%*[" .. table.concat(parts, " ") .. "%*]"
end

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LSPAttach", "BufEnter" }, {
  callback = function()
    update_lsp_diagnostic_cache()
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
  return lsp_diagnostic_cache
end

-- ----------------------------------------------------------------------------
-- LSP status
-- ----------------------------------------------------------------------------

local lsp_status_cache = {}

local function update_lsp_status_cache()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local icon = icons.lsp
  local status
  if vim.bo.buftype ~= "" then return "" end
  local lang_icon = icon.language[vim.bo.filetype] or icon.language.default
  if #clients > 0 then
    status = "%*[" .. "%#StatusLineLspEnabled#" .. lang_icon .. " " .. icon.indicator.enabled .. "%*]"
  else
    status = "%*[" .. "%#StatusLineLspDisabled#" .. lang_icon .. " " .. icon.indicator.disabled .. "%*]"
  end
  lsp_status_cache[vim.bo.filetype] = status
  return status
end

vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "BufEnter" }, {
  callback = function()
    if vim.bo.buftype == "" and lsp_configured_lang[vim.bo.filetype] then
      update_lsp_status_cache()
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
  return lsp_status_cache[vim.bo.filetype] or ""
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
  return index and string.format("[%s %d/%d]", icons.buffers, index, total) or ""
end

-- ----------------------------------------------------------------------------
-- Available plugin updates
-- ----------------------------------------------------------------------------

local lazy_plugin_updates_count = 0

function _G.lazy_plugin_updates()
  return lazy_plugin_updates_count > 0 and string.format("[%s %d]", icons.plugin_updates, lazy_plugin_updates_count) or ""
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local updates = require("lazy.status").updates()
    lazy_plugin_updates_count = updates and tonumber(updates) or 0
  end,
})

-- ----------------------------------------------------------------------------
-- StatusLine
-- ----------------------------------------------------------------------------

local statusline_components = {
  "%<",                                         -- Truncation point
  "%f",                                         -- File path
  " %m",                                        -- Modified flag
  "%r",                                         -- Readonly flag
  "%{%v:lua.git_status()%}",                    -- Git branch
  "%{%v:lua.lsp_status()%}",                    -- LSP status
  "%{%v:lua.lsp_diagnostic()%}",                -- LSP diagnostics
  "%=",                                         -- Left/right separator
  "%{%v:lua.lazy_plugin_updates()%}",           -- Number of plugins need update
  " %{%v:lua.buf_info()%}",                     -- Buffer count
  " [%{&fileencoding?&fileencoding:&encoding}", -- File encoding
  " %{&fileformat}]",                           -- File format
  " %l:%c",                                     -- Line and column
  " %P",                                        -- Percentage through file
}

vim.opt.statusline = table.concat(statusline_components, "")
