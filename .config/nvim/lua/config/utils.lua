local M = {}

-- -----------------------------------------------------------------------------
-- File size
-- -----------------------------------------------------------------------------

function M.get_current_file_size()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    return 0, false
  end
  local ok, stats = pcall(vim.loop.fs_stat, filepath)
  if ok and stats then
    return stats.size
  end
  return -1
end

function M.is_current_large_file(max_filesize, prompt)
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    return false
  end
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
-- Write with root priviledge
-- Credit: ibhagwan
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
-- Floating terminal
-- -----------------------------------------------------------------------------

local floating_term_bufnr = nil

local function is_buffer_visible(bufnr)
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win_id) == bufnr then
      return win_id
    end
  end
  return nil
end

local function toggle_floating_window(bufnr)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  }
  local win_id = vim.api.nvim_open_win(bufnr, true, opts)
  vim.api.nvim_set_option_value('winblend', 0, { win = win_id })
  return win_id
end

function M.toggle_floating_terminal()
  if not floating_term_bufnr or not vim.api.nvim_buf_is_valid(floating_term_bufnr) then
    floating_term_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_call(floating_term_bufnr, function() vim.cmd('terminal') end)
    vim.api.nvim_set_option_value('buflisted', false, { buf = floating_term_bufnr })
    vim.api.nvim_set_option_value('filetype', 'terminal', { buf = floating_term_bufnr })
    toggle_floating_window(floating_term_bufnr)
  else
    local win_id = is_buffer_visible(floating_term_bufnr)
    if win_id then
      vim.api.nvim_win_close(win_id, false)
    else
      toggle_floating_window(floating_term_bufnr)
    end
  end
end

-- -----------------------------------------------------------------------------
-- Close current buffer with proper window management
-- -----------------------------------------------------------------------------

-- Special buffers
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

local function is_floating_window(winid)
  local config = vim.api.nvim_win_get_config(winid)
  -- Check if 'relative' is set (indicating a floating window)
  return config.relative ~= "" and config.relative ~= nil
end

local function is_terminal_idle(bufnr)
  if vim.bo[bufnr].buftype ~= "terminal" then
    return true
  end
  local channel = vim.bo[bufnr].channel
  if not channel or channel <= 0 then
    return true
  end
  local job_id = vim.fn.jobpid(channel)
  if not job_id or job_id <= 0 then
    return true
  end
  -- Check for child processes, when executing a command, it spawns child process
  local handle = io.popen("pgrep -P " .. job_id .. " 2>/dev/null | wc -l")
  if handle then
    local result = handle:read("*a")
    handle:close()
    local count = tonumber(result and result:match("^%s*(%d+)%s*$"))
    if count and count == 0 then
      return true
    elseif count and count > 0 then
      return false
    end
  end
  return false
end

-- Select the most appropriate buffer to switch to after closing current buffer
-- Prioritizes non-displayed buffers over already displayed ones
local function select_buffer_to_switch(current_buf, valid_buffers)
  -- Get list of buffers displaying in any window (excluding current buffer)
  local displayed_buffers = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if buf ~= current_buf then
      displayed_buffers[buf] = true
    end
  end
  -- Find most recently used non-displayed buffer and overall MRU buffer
  local non_displayed_mru = -1
  local non_displayed_timestamp = -1
  local any_mru = -1
  local any_timestamp = -1
  for _, bufnr in ipairs(valid_buffers) do
    local bufinfo = vim.fn.getbufinfo(bufnr)[1]
    if bufinfo then
      local lastused = bufinfo.lastused
      -- Track overall MRU
      if lastused > any_timestamp then
        any_timestamp = lastused
        any_mru = bufnr
      end
      -- Track non-displayed MRU
      if not displayed_buffers[bufnr] and lastused > non_displayed_timestamp then
        non_displayed_timestamp = lastused
        non_displayed_mru = bufnr
      end
    end
  end
  -- Prioritize non-displayed buffer, fallback to any buffer
  local selected_bufnr = (non_displayed_mru ~= -1) and non_displayed_mru or any_mru
  -- If no buffer found, create a new one
  if selected_bufnr == -1 then
    selected_bufnr = vim.api.nvim_create_buf(true, false)
    if selected_bufnr == 0 then
      vim.notify("Failed to create a buffer to switch to", vim.log.levels.ERROR)
      return nil
    end
  end
  return selected_bufnr
end

-- Consolidate windows when there are more windows than normal buffers after closing buffer
local function consolidate_windows(valid_buffers)
  local normal_win_count = 0
  local windows = vim.api.nvim_list_wins()
  local current_win = vim.api.nvim_get_current_win()
  local buf_win_map = {}
  local win_to_close = {}
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    if is_normal_buffer(buf) then
      normal_win_count = normal_win_count + 1
      -- Marks the window as "primary" display for the buffer
      if not buf_win_map[buf] then
        buf_win_map[buf] = win
        -- Window with same buffer detected, duplicate
      else
        local existing_win = buf_win_map[buf]
        if existing_win == current_win then
          table.insert(win_to_close, win)
        elseif win == current_win then
          table.insert(win_to_close, existing_win)
          buf_win_map[buf] = win
        else
          table.insert(win_to_close, win)
        end
      end
    end
  end
  -- Consolidate if there are more windows than unique buffers
  if normal_win_count > #valid_buffers then
    -- Close windows in reverse order to avoid index invalidation
    table.sort(win_to_close, function(a, b) return a > b end)
    for _, win in ipairs(win_to_close) do
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end
end

function M.smart_close_buffer(force)
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()

  if is_floating_window(current_win) then
    vim.api.nvim_win_close(current_win, true)
    return
  end

  local filetype = vim.bo[current_buf].filetype
  local buftype = vim.bo[current_buf].buftype
  local bufname = vim.api.nvim_buf_get_name(current_buf)
  local bufmodified = vim.bo[current_buf].modified

  local ignore_changes = force or false

  -- Handle special buffers - close window directly
  if buf_config.filetypes[filetype] or buf_config.buftypes[buftype] then
    if filetype == "undotree" then
      vim.cmd("UndotreeHide")
      return
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

  -- Prompt for confirmation if buffer is modified
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
    else
      return
    end
  end

  -- Prompt for confirmation if terminal has any job running
  if not ignore_changes and buftype == "terminal" then
    local job_state = vim.fn.jobwait({ vim.bo[current_buf].channel }, 0)
    if job_state and job_state[1] == -1 and not is_terminal_idle(current_buf) then
      local choice = vim.fn.confirm(
        string.format("Terminal has job running. (%s)", (bufname ~= "" and bufname or "[No Name]")),
        "&Ignore\n&Cancel", 1)
      if choice == 1 then
        ignore_changes = true
      else
        return
      end
    else
      ignore_changes = true
    end
  end

  -- Get list of valid and listed buffers (excluding current buffer)
  local rest_valid_buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and buf ~= current_buf
  end, vim.api.nvim_list_bufs())
  -- Quit neovim if there will be no valid buffer after closing buffer
  if #rest_valid_buffers == 0 then
    vim.cmd("silent! quit!")
    return
  end

  -- Select a buffer to switch to after closing current buffer
  local bufnr_switched_to = select_buffer_to_switch(current_buf, rest_valid_buffers)
  if not bufnr_switched_to then
    return
  end

  -- Get list of windows displaying the current buffer
  local wins_displaying_current_buf = vim.tbl_filter(function(win)
    return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == current_buf
  end, vim.api.nvim_list_wins())

  -- Switch all windows of current buffer to the new buffer
  for _, win in ipairs(wins_displaying_current_buf) do
    vim.api.nvim_win_set_buf(win, bufnr_switched_to)
  end

  -- Do final buffer close
  local use_force = ignore_changes or buftype == "terminal"
  local ok = pcall(vim.cmd, "silent! bdelete" .. (use_force and "!" or "") .. " " .. current_buf)
  if not ok then
    vim.notify("Fail to delete buffer", vim.log.levels.ERROR)
  end

  -- Quit neovim if only quickfix buffer remains after closing buffer
  if #rest_valid_buffers == 1 then
    local last_valid_buf = vim.api.nvim_get_current_buf()
    if vim.bo[last_valid_buf].buftype == "quickfix" then
      vim.cmd("qa!")
    end
  end

  -- Perform window consolidation after buffer close if needed
  consolidate_windows(rest_valid_buffers)
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
