local M = {}

-- -----------------------------------------------------------------------------
-- File size
-- -----------------------------------------------------------------------------

function M.get_current_file_size()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then return 0, false end
  local ok, stats = pcall(vim.loop.fs_stat, filepath)
  if ok and stats then
    return stats.size
  end
  return -1
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

local buf_config = {
  filetypes = {
    help = { force = false },
    qf = { force = false },
    netrw = { force = false },
    fugitive = { force = false },
    undotree = { force = false },
    aerial = { force = false },
    oil = { force = false },
    harpoon = { force = true },
    TelescopePrompt = { force = true },
  },
  buftypes = {
    quickfix = { force = false },
    prompt = { force = false },
    nofile = { force = false },
    acwrite = { force = false },
    nowrite = { force = false },
  },
}

local function is_normal_buffer(bufnr)
  local filetype = vim.bo[bufnr].filetype
  local buftype = vim.bo[bufnr].buftype
  if buf_config.filetypes[filetype] or buf_config.buftypes[buftype] then
    return false
  end
  return true
end

function M.smart_delete_buffer(force)
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()

  local filetype = vim.bo[current_buf].filetype
  local buftype = vim.bo[current_buf].buftype
  local bufname = vim.api.nvim_buf_get_name(current_buf)
  local bufmodified = vim.bo[current_buf].modified

  local ignore_changes = force or false

  -- Handle special buffers - close window directly
  if buf_config.filetypes[filetype] or buf_config.buftypes[buftype] then
    if filetype == "undotree" then
      return vim.cmd("UndotreeHide")
    end
    if #vim.api.nvim_list_wins() > 1 then
      local f = force
      if buf_config.filetypes[filetype] then
        f = buf_config.filetypes[filetype].force
      elseif buf_config.buftypes[buftype] then
        f = buf_config.buftypes[buftype].force
      end
      vim.api.nvim_win_close(current_win, f)
      return
    end
  end

  if not ignore_changes and bufmodified then
    local choice = vim.fn.confirm(
      string.format("Save before closing the buffer? (%s)", (bufname ~= "" and bufname or "[No Name]")),
      "&Yes\n&No\n&Cancel", 1)
    if choice == 1 then
      local ok = pcall(vim.cmd, "silent! write")
      if not ok then
        vim.notify("Failed to save buffer!", vim.log.levels.ERROR)
        return
      end
      bufmodified = false
    elseif choice == 2 then
      ignore_changes = true
    elseif choice == 3 then
      return
    end
  end

  if not ignore_changes and buftype == "terminal" then
    local job_state = vim.fn.jobwait({ vim.bo[current_buf].channel }, 0)
    if job_state and job_state[1] == -1 then
      local choice = vim.fn.confirm(
        string.format("Terminal is still running. (%s)", (bufname ~= "" and bufname or "[No Name]")),
        "&Ignore\n&Cancel", 1)
      if choice == 1 then
        ignore_changes = true
      else
        return
      end
    end
  end

  -- Get list of valid and listed buffers (excluding current buffer)
  local rest_valid_buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and buf ~= current_buf
  end, vim.api.nvim_list_bufs())

  if #rest_valid_buffers == 0 then
    if ignore_changes or not bufmodified then
      vim.cmd("silent! quit" .. (ignore_changes and "!" or ""))
    else
      local choice = vim.fn.confirm("Save before quitting nvim?", "&Yes\n&No\n&Cancel", 1)
      if choice == 1 then
        vim.cmd("silent! write")
        vim.cmd("quit")
      elseif choice == 2 then
        vim.cmd("quit!")
      end
    end
    return
  end

  local normal_buf_count = 0
  local first_noremal_buf_to_keep = nil
  for _, buf in ipairs(rest_valid_buffers) do
    if is_normal_buffer(buf) then
      normal_buf_count = normal_buf_count + 1
      if not first_noremal_buf_to_keep then
        first_noremal_buf_to_keep = buf
      end
    end
  end

  -- Consolidate all windows if only one normal buffer remain
  if normal_buf_count == 1 and #vim.api.nvim_list_wins() > 1 then
    if first_noremal_buf_to_keep then
      local win_to_keep = current_win
      vim.api.nvim_win_set_buf(win_to_keep, first_noremal_buf_to_keep)
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if win ~= win_to_keep then
          vim.api.nvim_win_close(win, true)
        end
      end
      local use_force = ignore_changes or buftype == "terminal"
      vim.cmd("silent! bdelete" .. (use_force and "!" or "") .. " " .. current_buf)
      return
    end
  end

  -- Find most recently used buffer to switch to
  local bufnr_switched_to = -1
  local max_lastused_timestamp = -1

  for _, bufnr in ipairs(rest_valid_buffers) do
    local bufinfo = vim.fn.getbufinfo(bufnr)[1]
    if bufinfo and bufinfo.lastused > max_lastused_timestamp then
      max_lastused_timestamp = bufinfo.lastused
      bufnr_switched_to = bufnr
    end
  end

  if bufnr_switched_to == -1 then
    bufnr_switched_to = vim.api.nvim_create_buf(true, false)
    if bufnr_switched_to == 0 then
      vim.notify("Failed to create a buffer to switch to", vim.log.levels.ERROR)
      return
    end
  end

  -- Get list of windows displaying the current buffer
  local wins_displaying_current_buf = vim.tbl_filter(function(win)
    return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == current_buf
  end, vim.api.nvim_list_wins())

  -- Switch all windows of current buffer to the new buffer
  for _, win in ipairs(wins_displaying_current_buf) do
    vim.api.nvim_win_set_buf(win, bufnr_switched_to)
  end

  local use_force = ignore_changes or buftype == "terminal"
  local ok = pcall(vim.cmd, "silent! bdelete" .. (use_force and "!" or "") .. " " .. current_buf)
  if not ok then
    vim.notify("Fail to delete buffer", vim.log.levels.ERROR)
  end

  if #rest_valid_buffers == 1 then
    local last_valid_buf = vim.api.nvim_get_current_buf()
    if vim.bo[last_valid_buf].buftype == "quickfix" then
      vim.cmd("qa!")
    end
  end
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
