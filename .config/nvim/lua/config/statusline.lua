-- -----------------------------------------------------------------------------
-- Constants
-- -----------------------------------------------------------------------------

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
  plugin_updates = " ",
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
  ["AA"] = "both added",
  ["UU"] = "both modified",
  ["DD"] = "both deleted",
  ["AU"] = "added by us",
  ["UA"] = "added by them",
  ["DU"] = "deleted by us",
  ["UD"] = "deleted by them",
}

local cache = {
  git_file_status = {},
  lsp_status = {},
  lsp_diagnostic = {},
  plugin_updates = "",
  nvim_startup_done = false,
}

-- -----------------------------------------------------------------------------
-- Git status
-- -----------------------------------------------------------------------------

local function get_git_root(file_path)
  local git_cmd = { "git", "-C", vim.fn.fnamemodify(file_path, ":h"), "rev-parse", "--show-toplevel" }
  local git_root = vim.fn.systemlist(git_cmd)[1]
  return vim.v.shell_error == 0 and git_root or nil
end

local function should_show_git_status()
  return vim.bo.buftype == "" and vim.bo.filetype ~= "netrw"
end

local function update_git_file_status_cache()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" or vim.bo.buftype ~= "" then
    cache.git_file_status[bufnr] = ""
    return ""
  end
  local resolved_file_path = vim.fn.resolve(bufname)
  local git_root = get_git_root(resolved_file_path)
  if not git_root then
    cache.git_file_status[bufnr] = ""
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
  cache.git_file_status[bufnr] = status
  return status
end

local function git_status()
  if not should_show_git_status() then return "" end
  return cache.git_file_status[vim.api.nvim_get_current_buf()] or update_git_file_status_cache()
end

-- -----------------------------------------------------------------------------
-- LSP status
-- -----------------------------------------------------------------------------

local function update_lsp_status_cache()
  if not lsp_configured_lang[vim.bo.filetype] then return "" end
  if vim.bo.buftype ~= "" then return "" end
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local icon = icons.lsp
  local status
  local lang_icon = icon.language[vim.bo.filetype] or icon.language.default
  if #clients > 0 then
    status = "%*[" .. "%#StatusLineLspEnabled#" .. lang_icon .. " " .. icon.indicator.enabled .. "%*]"
  else
    status = "%*[" .. "%#StatusLineLspDisabled#" .. lang_icon .. " " .. icon.indicator.disabled .. "%*]"
  end
  cache.lsp_status[vim.bo.filetype] = status
  return status
end

local function lsp_status()
  return cache.lsp_status[vim.bo.filetype] or ""
end

-- -----------------------------------------------------------------------------
-- LSP diagnostic
-- -----------------------------------------------------------------------------

local function update_lsp_diagnostic_cache()
  local bufnr = vim.api.nvim_get_current_buf()
  if #vim.diagnostic.get(bufnr) == 0 then
    cache.lsp_diagnostic[bufnr] = ""
    return
  end
  local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
  local infos = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO })
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
  cache.lsp_diagnostic[bufnr] = "%*[" .. table.concat(parts, " ") .. "%*]"
end

local function lsp_diagnostic()
  return cache.lsp_diagnostic[vim.api.nvim_get_current_buf()] or ""
end

-- -----------------------------------------------------------------------------
-- Buffers
-- -----------------------------------------------------------------------------

local function buffer_index()
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

-- -----------------------------------------------------------------------------
-- Available plugin updates
-- -----------------------------------------------------------------------------

local function available_plugin_updates()
  return cache.plugin_updates ~= "" and string.format("[%s]", cache.plugin_updates) or ""
end

-- -----------------------------------------------------------------------------
-- Utility
-- -----------------------------------------------------------------------------

local function setup_highlight_groups()
  local statusline_bg = vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg
  for _, hl_group in ipairs({
    { name = "StatusLineLspEnabled", src = "DiagnosticOk" },
    { name = "StatusLineDiagnosticError", src = "DiagnosticError" },
    { name = "StatusLineDiagnosticWarn", src = "DiagnosticWarn" },
    { name = "StatusLineDiagnosticInfo", src = "DiagnosticInfo" },
    -- { name = "StatusLineDiagnosticHint", src = "DiagnosticHint" },
  }) do
    vim.api.nvim_set_hl(0, hl_group.name, {
      fg = vim.api.nvim_get_hl(0, { name = hl_group.src }).fg,
      bg = statusline_bg,
    })
  end
end

local function expose_statusline_functions()
  _G.git_status = git_status
  _G.lsp_status = lsp_status
  _G.lsp_diagnostic = lsp_diagnostic
  _G.buffer_index = buffer_index
  _G.available_plugin_updates = available_plugin_updates
  _G.update_git_file_status_cache = update_git_file_status_cache
end

-- -----------------------------------------------------------------------------
-- Define module to expose
-- -----------------------------------------------------------------------------

local M = {}

M.update_highlight_groups = setup_highlight_groups

function M.setup()
  expose_statusline_functions()
  setup_highlight_groups()

  update_git_file_status_cache()
  update_lsp_status_cache()
  update_lsp_diagnostic_cache()

  local statusline_components = {
    "%<",                                          -- Truncation point
    "%f",                                          -- File path
    " %m",                                         -- Modified flag
    "%r",                                          -- Readonly flag
    "%{%v:lua.git_status()%}",                     -- Git branch
    "%{%v:lua.lsp_status()%}",                     -- LSP status
    "%{%v:lua.lsp_diagnostic()%}",                 -- LSP diagnostics
    "%=",                                          -- Left/right separator
    "%{%v:lua.available_plugin_updates()%}",       -- Number of available updates
    " %{%v:lua.buffer_index()%}",                  -- Buffer index
    " [%{&fileencoding?&fileencoding:&encoding}",  -- File encoding
    " %{&fileformat}]",                            -- File format
    " %-7(%l:%c%)",                                -- Line and column
    " %P",                                         -- Percentage through file
  }

  vim.opt.statusline = table.concat(statusline_components, "")

  local augroup = vim.api.nvim_create_augroup("nvim_custom_statusline_ac", { clear = true })
  local autocmd = vim.api.nvim_create_autocmd

  autocmd("VimEnter", {
    group = augroup,
    callback = function()
      cache.nvim_startup_done = true
    end,
  })

  autocmd({ "BufReadPost", "BufNewFile", "BufWritePost", "FileChangedShellPost" }, {
    group = augroup,
    callback = function()
      if cache.nvim_startup_done and should_show_git_status() then
        update_git_file_status_cache()
      end
    end,
  })

  autocmd({ "LspAttach", "LspDetach", "FileType" }, {
    group = augroup,
    callback = function()
      if vim.bo.buftype == "" then
        update_lsp_status_cache()
      end
    end,
  })

  autocmd({ "DiagnosticChanged", "LSPAttach", "BufEnter" }, {
    group = augroup,
    callback = function()
      update_lsp_diagnostic_cache()
      vim.cmd("redrawstatus")
    end,
  })

  autocmd("User", {
    group = augroup,
    pattern = "LazyCheck",
    callback = function()
      cache.plugin_updates = require("lazy.status").updates() or ""
      vim.cmd("redrawstatus")
    end,
  })

  autocmd("BufDelete", {
    group = augroup,
    callback = function(args)
      local bufnr = args.buf
      cache.git_file_status[bufnr] = nil
      cache.lsp_diagnostic[bufnr] = nil
    end,
  })
end

return M
