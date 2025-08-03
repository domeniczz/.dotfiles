-- -----------------------------------------------------------------------------
-- Constants
-- -----------------------------------------------------------------------------

local icons = {
  git = {
    clean = "󰊢", dirty = "",
  },
  lsp_diagnostics = {
    error = "", warn = "", info = "", hint = "",
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
      c = "",
      cpp = "",
      csharp = "",
      rust = "󱘗",
      ruby = "󰴭",
      go = "",
      java = "󰬷",
      kotlin = "󱈙",
      html = "",
      css = "",
      default = "󰈮",
    },
  },
  buffers = "",
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
  lsp_diagnostics = {},
  plugin_updates = "",
}

-- -----------------------------------------------------------------------------
-- Relative file path
-- -----------------------------------------------------------------------------

local function get_relative_file_path()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  if bufname == "" then return "[No Name]" end
  if vim.bo[bufnr].buftype ~= "" then return bufname end

  local relative = vim.fn.fnamemodify(bufname, ":.")
  if relative:sub(1, 1) == "/" then
    return vim.fn.fnamemodify(bufname, ":~")
  end
  return relative
end

-- -----------------------------------------------------------------------------
-- Git branch and file status
-- -----------------------------------------------------------------------------

local function get_git_root(file_path)
  local dir = vim.fs.dirname(file_path)
  if not dir then return nil end
  local git_item = vim.fs.find('.git', { path = dir, upward = true, limit = 1 })[1]
  return git_item and vim.fs.normalize(vim.fs.dirname(git_item))
end

local function should_show_git_status()
  return vim.bo.buftype == "" and vim.bo.filetype ~= "netrw"
end

local function update_git_file_status_cache()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" or not should_show_git_status() then
    cache.git_file_status[bufnr] = ""
    return ""
  end

  local resolved_file_path = vim.fn.resolve(bufname)
  local git_root = get_git_root(resolved_file_path)
  if not git_root then
    cache.git_file_status[bufnr] = ""
    return ""
  end

  local branch_name = ""
  local git_branch_cmd = { "git", "-C", git_root, "--no-optional-locks", "branch", "--show-current" }
  local branch_res = vim.fn.systemlist(git_branch_cmd)
  if vim.v.shell_error == 0 then
    if branch_res and #branch_res > 0 then
      branch_name = branch_res[1]
    else
      local git_hash_cmd = { "git", "-C", git_root, "--no-optional-locks", "rev-parse", "--short", "HEAD" }
      local hash_res = vim.fn.systemlist(git_hash_cmd)
      if hash_res and #hash_res > 0 and vim.v.shell_error == 0 then
        branch_name = hash_res[1]
      else
        branch_name = "detached"
      end
    end
  end

  local relative_file_path = ""
  local abs_file_path = vim.fs.normalize(resolved_file_path)
  if vim.startswith(abs_file_path, git_root .. "/") then
    relative_file_path = abs_file_path:sub(#git_root + 2)
  else
    relative_file_path = vim.fn.fnamemodify(resolved_file_path, ":t")
  end

  local git_status = ""
  local git_status_cmd = { "git", "-C", git_root, "--no-optional-locks", "status",
    "--porcelain=v1", "--untracked-files=all", "--ignored=matching", "--", relative_file_path }
  local git_status_res = vim.fn.systemlist(git_status_cmd)
  if branch_res and #branch_res > 0 and vim.v.shell_error == 0 then
    git_status = git_status_res[1]
  end

  local icon, status_text
  if git_status then
    icon = icons.git.dirty
    local status_code = git_status:sub(1, 2):gsub("%s$", ""):sub(1, 2)
    status_text = git_file_status[status_code] or "unknown"
  else
    icon = icons.git.clean
    status_text = "unmodified"
  end

  local status = "[" .. icon .. " " .. branch_name .. " " .. status_text .. "]"
  cache.git_file_status[bufnr] = status
  return status
end

local function get_git_status()
  if not should_show_git_status() then return "" end
  return cache.git_file_status[vim.api.nvim_get_current_buf()] or update_git_file_status_cache()
end

-- -----------------------------------------------------------------------------
-- LSP status
-- -----------------------------------------------------------------------------

local function update_lsp_status_cache()
  local filetype = vim.bo.filetype
  if not lsp_configured_lang[filetype] or vim.bo.buftype ~= "" then return "" end
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local icon = icons.lsp
  local status_text
  local lang_icon = icon.language[filetype] or icon.language.default
  if #clients > 0 then
    status_text = "%*[" .. "%#StatusLineLspEnabled#" .. lang_icon .. " " .. icon.indicator.enabled .. "%*]"
  else
    status_text = "%*[" .. "%#StatusLineLspDisabled#" .. lang_icon .. " " .. icon.indicator.disabled .. "%*]"
  end
  cache.lsp_status[filetype] = status_text
  return status_text
end

local function get_lsp_status()
  return cache.lsp_status[vim.bo.filetype] or ""
end

-- -----------------------------------------------------------------------------
-- LSP diagnostic
-- -----------------------------------------------------------------------------

local function update_lsp_diagnostics_cache()
  local bufnr = vim.api.nvim_get_current_buf()
  if #vim.diagnostic.get(bufnr) == 0 then
    cache.lsp_diagnostics[bufnr] = ""
    return
  end
  local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
  local infos = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO })
  local parts = {}
  local icon = icons.lsp_diagnostics
  if errors > 0 then
    table.insert(parts, "%#StatusLineDiagnosticError#" .. icon.error .. " " .. errors)
  end
  if warnings > 0 then
    table.insert(parts, "%#StatusLineDiagnosticWarn#" .. icon.warn .. " " .. warnings)
  end
  if infos > 0 then
    table.insert(parts, "%#StatusLineDiagnosticHint#" .. icon.info .. " " .. infos)
  end
  if errors == 0 and warnings == 0 then
    cache.lsp_diagnostics[bufnr] = ""
    return
  end
  cache.lsp_diagnostics[bufnr] = "%*[" .. table.concat(parts, " ") .. "%*]"
end

local function get_lsp_diagnostics()
  return cache.lsp_diagnostics[vim.api.nvim_get_current_buf()] or ""
end

-- -----------------------------------------------------------------------------
-- Buffers
-- -----------------------------------------------------------------------------

local function get_buffer_index()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local total = #bufs
  if total <= 1 then return "" end
  local current_buf = vim.api.nvim_get_current_buf()
  local index = 0
  for i, buf in ipairs(bufs) do
    if buf.bufnr == current_buf then
      index = i
      break
    end
  end
  return index and string.format("[%s %d/%d]", icons.buffers, index, total) or ""
end

-- -----------------------------------------------------------------------------
-- Available plugin updates
-- -----------------------------------------------------------------------------

local function get_available_plugin_updates()
  local updates = cache.plugin_updates
  return updates and updates ~= "" and string.format("[%s]", updates) or ""
end

-- -----------------------------------------------------------------------------
-- Utility
-- -----------------------------------------------------------------------------

local function setup_highlight_groups()
  local statusline_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
  local statusline_bg = statusline_hl.bg
  local hl_groups_to_set = {
    { name = "StatusLineLspEnabled",      src = "DiagnosticOk" },
    { name = "StatusLineDiagnosticError", src = "DiagnosticError" },
    { name = "StatusLineDiagnosticWarn",  src = "DiagnosticWarn" },
    { name = "StatusLineDiagnosticInfo",  src = "DiagnosticInfo" },
  }
  for _, hl_group in ipairs(hl_groups_to_set) do
    vim.api.nvim_set_hl(0, hl_group.name, {
      fg = vim.api.nvim_get_hl(0, { name = hl_group.src }).fg,
      bg = statusline_bg,
    })
  end
end

-- -----------------------------------------------------------------------------
-- Setup module to expose
-- -----------------------------------------------------------------------------

local M = {}

M.update_highlight_groups = setup_highlight_groups

function M.setup()
  _G._statusline_module = {
    relative_path = get_relative_file_path,
    git = get_git_status,
    lsp = get_lsp_status,
    diagnostics = get_lsp_diagnostics,
    buffers = get_buffer_index,
    updates = get_available_plugin_updates,
  }

  setup_highlight_groups()

  update_git_file_status_cache()
  update_lsp_status_cache()
  update_lsp_diagnostics_cache()

  local statusline_components = {
    "%<",                                            -- Truncation point
    "%{%v:lua._statusline_module.relative_path()%}", -- File path
    " %m",                                           -- Modified flag
    "%r",                                            -- Readonly flag
    "%{%v:lua._statusline_module.git()%}",           -- Git branch and file status
    " %{%v:lua._statusline_module.lsp()%}",          -- LSP status
    " %{%v:lua._statusline_module.diagnostics()%}",  -- LSP diagnostics
    "%=",                                            -- Left/Right separator
    "%{%v:lua._statusline_module.updates()%}",       -- Total available updates
    " %{%v:lua._statusline_module.buffers()%}",      -- Buffer index
    " [%{&fileencoding?&fileencoding:&encoding}",    -- File encoding
    " %{&fileformat}]",                              -- File format
    " %-7(%l:%c%)",                                  -- Line and column
    " %P",                                           -- Percentage through file
  }

  vim.opt.statusline = table.concat(statusline_components, "")

  local augroup = vim.api.nvim_create_augroup("_nvim_user_statusline_ac_", { clear = true })
  local autocmd = vim.api.nvim_create_autocmd

  autocmd({ "BufReadPost", "BufWritePost", "FileChangedShellPost" }, {
    group = augroup,
    callback = function()
      if should_show_git_status() then
        update_git_file_status_cache()
      end
    end,
  })

  autocmd({ "LspAttach", "LspDetach", "FileType" }, {
    group = augroup,
    callback = function()
      if vim.bo.buftype == "" then
        vim.schedule(function()
          update_lsp_status_cache()
        end)
      end
    end,
  })

  autocmd({ "DiagnosticChanged", "LSPAttach" }, {
    group = augroup,
    callback = function()
      update_lsp_diagnostics_cache()
      vim.cmd("redrawstatus")
    end,
  })

  autocmd("User", {
    group = augroup,
    pattern = { "LazySync", "LazyInstall", "LazyUpdate", "LazyCheck" },
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
      cache.lsp_diagnostics[bufnr] = nil
    end,
  })

  autocmd("ColorScheme", {
    group = augroup,
    callback = function()
      setup_highlight_groups()
    end,
  })
end

return M
