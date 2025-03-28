local M = {}

-- -----------------------------------------------------------------------------
-- File size
-- -----------------------------------------------------------------------------

function M.get_current_file_size()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then return 0, false end
  local ok, stats = pcall(vim.loop.fs_stat, vim.fn.expand("%"))
  if ok and stats then return stats.size, true end
  return 0, false
end

function M.is_current_large_file(max_filesize, prompt)
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then return false end
  local ok, stats = pcall(vim.loop.fs_stat, vim.fn.expand("%"))
  if ok and stats and stats.size > max_filesize then
    vim.notify(
      prompt or string.format("File larger than %sKB", max_filesize / 1024),
      vim.log.levels.WARN,
      { title = "Large File" }
    )
    return true
  end
  return false
end

-- -----------------------------------------------------------------------------
-- Delete current buffer
-- -----------------------------------------------------------------------------

local function delete_buf_preserve_win_layout(bufnr, opts)
  opts = opts or { force = false, has_valid_buffer = true }
  if #vim.api.nvim_list_wins() == 1 then
    return vim.api.nvim_buf_delete(bufnr, { force = opts.force })
  else
    if #vim.fn.win_findbuf(vim.api.nvim_get_current_buf()) > 1 then
      if not opts.has_valid_buffer then return end
      return vim.api.nvim_buf_delete(bufnr, { force = opts.force })
    end
  end
  local alternate_buf = vim.fn.bufnr('#')
  if alternate_buf ~= -1 and alternate_buf ~= bufnr and vim.api.nvim_buf_is_valid(alternate_buf) then
    vim.api.nvim_set_current_buf(alternate_buf)
    vim.api.nvim_buf_delete(bufnr, { force = opts.force })
  else
    vim.api.nvim_buf_delete(bufnr, { force = opts.force })
  end
end

function M.kill_buffer_or_close_window()
  if vim.fn.getcmdwintype() ~= "" then return vim.cmd("quit") end

  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()

  if vim.bo[current_buf].buftype == "terminal" or vim.bo[current_buf].filetype == "terminal" then
    return delete_buf_preserve_win_layout(current_buf)
  end

  local clients = vim.lsp.get_clients({ bufnr = current_buf })
  for _, client in ipairs(clients) do
    vim.lsp.buf_detach_client(current_buf, client.id)
  end

  local has_valid_buffer = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and buf ~= current_buf then
      has_valid_buffer = true
      break
    end
  end
  local should_quit = not has_valid_buffer

  local special_buf = {
    lazy = { force = false },
    fugitive = { force = false },
    netrw = { force = false },
    aerial = { force = false },
    harpoon = { force = true },
    TelescopePrompt = { force = true },
  }
  local buf_ft = vim.bo[current_buf].filetype
  if special_buf[buf_ft] then
    vim.api.nvim_buf_delete(current_buf, { force = special_buf[buf_ft].force })
    return
  elseif buf_ft == "undotree" then
    vim.cmd("UndotreeHide")
    return
  elseif buf_ft == "oil" then
    if vim.bo[current_buf].modified then
      vim.cmd("write")
    else
      delete_buf_preserve_win_layout(current_buf)
    end
    if should_quit then vim.cmd("quit") end
    return
  elseif buf_ft == "help" or buf_ft == "qf" then
    vim.api.nvim_win_close(current_win, false)
  end

  local force = false
  if vim.bo[current_buf].modified then
    local choice = vim.fn.confirm("Buffer has unsaved changes. Save before closing?", "&Yes\n&No\n&Cancel", 1)
    if choice == 1 then
      local filename = vim.fn.bufname(current_buf)
      if filename == "" then
        filename = vim.fn.input("Enter file name to save: ")
        if filename == "" then return end
      end
      local success, err = pcall(vim.cmd, "silent! write " .. vim.fn.fnameescape(filename))
      if not success then
        return vim.api.notify("Failed to save buffer: " .. tostring(err))
      end
    elseif choice == 2 then
      force = true
    else
      return
    end
  end
  delete_buf_preserve_win_layout(current_buf, { force = force, has_valid_buffer = has_valid_buffer })

  if should_quit then vim.cmd("quit") end
end

-- -----------------------------------------------------------------------------
-- Write with root priviledge
-- -----------------------------------------------------------------------------

local function fast_event_aware_notify(msg, level, opts)
  if vim.in_fast_event() then
    vim.schedule(function()
      vim.notify(msg, level, opts)
    end)
  else
    vim.notify(msg, level, opts)
  end
end

local function info(msg)
  fast_event_aware_notify(msg, vim.log.levels.INFO, {})
end

local function warn(msg)
  fast_event_aware_notify(msg, vim.log.levels.WARN, {})
end

local function err(msg)
  fast_event_aware_notify(msg, vim.log.levels.ERROR, {})
end

local function sudo_exec(cmd, print_output)
  vim.fn.inputsave()
  local password = vim.fn.inputsecret("Password: ")
  vim.fn.inputrestore()
  if not password or #password == 0 then
    warn("Invalid password, sudo aborted!")
    return false
  end
  local out = vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
  if vim.v.shell_error ~= 0 then
    print("\r\n")
    err(out)
    return false
  end
  if print_output then print("\r\n", out) end
  return true
end

-- Credit: ibhagwan
function M.sudo_write(tmpfile, filepath)
  if not tmpfile then tmpfile = vim.fn.tempname() end
  if not filepath then filepath = vim.fn.expand("%") end
  if not filepath or #filepath == 0 then
    err("E32: No file name")
    return
  end
  -- `bs=1048576` is equivalent to `bs=1M` for GNU dd or `bs=1m` for BSD dd
  -- Both `bs=1M` and `bs=1m` are non-POSIX
  local cmd = string.format("dd if=%s of=%s bs=1048576", vim.fn.shellescape(tmpfile), vim.fn.shellescape(filepath))
  -- no need to check error as this fails the entire function
  vim.api.nvim_exec2(string.format("write! %s", tmpfile), { output = true })
  if sudo_exec(cmd) then
    -- refreshes the buffer and prints the "written" message
    vim.cmd.checktime()
    -- exit command mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  end
  vim.fn.delete(tmpfile)
end

-- -----------------------------------------------------------------------------
-- Log
-- -----------------------------------------------------------------------------

local log_file = vim.fn.stdpath("cache") .. "/nvim_debug_log.log"

function M.log(message)
  local file = io.open(log_file, "a")
  if file then
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    file:write(string.format("[%s] %s\n", timestamp, message))
    file:close()
  end
end

return M
