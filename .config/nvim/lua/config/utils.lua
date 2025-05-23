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
--
-- 1. Window Layout Management:
--    - Preserve window layout after buffer closure
--    - When `prune_extra_wins` is enabled, eliminate redundant windows if
--      window count exceeds buffer count
--
-- 2. Buffer Type Handling:
--    - Special handling for special buffers in `buf_config`
--      (help, quickfix, plugin, etc.)
--    - Prompt for confirmation before closing terminal buffer with active jobs
--
-- 3. Buffer Lifecycle Management:
--    - When no normal buffers remain: either quit Neovim (`quit_on_empty=true`)
--      or create a new buffer (`quit_on_empty=false`)
--    - Prompt for saving modified buffers before closing
--    - Select the most appropriate buffer to display after closure
-- -----------------------------------------------------------------------------

-- Special buffer configurations
local buf_config = {
  filetypes = {
    help = {},
    qf = {},
    netrw = {},
    fugitive = {},
    undotree = { close_cmd = "UndotreeHide" },
    aerial = { close_cmd = "AerialClose" },
    oil = { pass = true },
  },
  buftypes = {
    prompt = {},
    nofile = {},
    acwrite = {},
    nowrite = {},
  },
}

local function is_special_buffer(bufnr)
  local filetype = vim.bo[bufnr].filetype
  local buftype = vim.bo[bufnr].buftype
  return buf_config.filetypes[filetype] ~= nil or buf_config.buftypes[buftype] ~= nil
end

local function is_floating_window(winid)
  local config = vim.api.nvim_win_get_config(winid)
  -- Check if 'relative' is set (indicating a floating window)
  return config.relative and config.relative ~= ""
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
  -- Check for child processes
  -- When executing a command in terminal, it spawns child process
  local handle = io.popen("pgrep -P " .. job_id .. " 2>/dev/null | wc -l")
  if not handle then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  local child_process_count = tonumber(result and result:match("^%s*(%d+)%s*$"))
  return child_process_count and child_process_count == 0
end

-- Select the most appropriate buffer to switch to after closing current buffer
-- Prioritizes non-displayed buffers over already displayed ones
local function select_buffer_to_switch(current_buf, valid_buffers)
  if #valid_buffers == 0 then
    local new_buf = vim.api.nvim_create_buf(true, false)
    if new_buf == 0 then
      vim.notify("Failed to create a new buffer", vim.log.levels.ERROR)
      return nil
    end
    return new_buf
  end
  local displayed_buffers = {}
  -- Get a list of buffers currently displaying in any window (excluding current buffer)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if buf ~= current_buf then
        displayed_buffers[buf] = true
      end
    end
  end
  -- Find most recently used non-displayed buffer, as well as overall MRU buffer
  local non_displayed = { mru_bufnr = -1, timestamp = -1 }
  local any = { mru_bufnr = -1, timestamp = -1 }
  for _, bufnr in ipairs(valid_buffers) do
    local bufinfo = vim.fn.getbufinfo(bufnr)[1]
    if bufinfo then
      local lastused = bufinfo.lastused
      -- Track overall MRU
      if lastused > any.timestamp then
        any.timestamp = lastused
        any.mru_bufnr = bufnr
      end
      -- Track non-displayed MRU
      if not displayed_buffers[bufnr] and lastused > non_displayed.timestamp then
        non_displayed.timestamp = lastused
        non_displayed.mru_bufnr = bufnr
      end
    end
  end
  -- Prioritize non-displayed buffer, fallback to any buffer
  return non_displayed.mru_bufnr ~= -1 and non_displayed.mru_bufnr or any.mru_bufnr
end

-- Consolidate windows when there are more windows than unique normal buffers after closing buffer
-- In this case, some windows will display same buffers, thus we can prune extra windows
local function consolidate_windows(valid_normal_buffers)
  local windows = vim.api.nvim_list_wins()
  local current_win = vim.api.nvim_get_current_win()
  local buf_win_map = {}
  local wins_to_close = {}
  local normal_win_count = 0
  -- Map buffers to windows and find duplicates
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    if not is_special_buffer(buf) then
      normal_win_count = normal_win_count + 1
      -- Marks the window as "primary" display for the buffer
      if not buf_win_map[buf] then
        buf_win_map[buf] = win
        -- Window with same buffer detected, duplicate
      else
        local existing_win = buf_win_map[buf]
        if existing_win == current_win then
          table.insert(wins_to_close, win)
        elseif win == current_win then
          table.insert(wins_to_close, existing_win)
          buf_win_map[buf] = win
        else
          table.insert(wins_to_close, win)
        end
      end
    end
  end
  -- Only consolidate if there are more windows than unique normal buffers
  if normal_win_count <= #valid_normal_buffers then
    return
  end
  -- Close windows in reverse order to avoid index invalidation
  table.sort(wins_to_close, function(a, b) return a > b end)
  for _, win in ipairs(wins_to_close) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
end

-- Apply default values to function arguments
local function apply_defaults(user_opts, defaults)
  return vim.tbl_deep_extend("force", {}, defaults, user_opts or {})
end

function M.smart_buffer_close(user_opts)
  local opts = apply_defaults(user_opts, {
    force = false,
    quit_on_empty = true,
    prune_extra_wins = true,
  })

  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local current_win_list = vim.api.nvim_list_wins()

  if is_floating_window(current_win) then
    vim.api.nvim_win_close(current_win, true)
    return
  end

  local filetype = vim.bo[current_buf].filetype
  local buftype = vim.bo[current_buf].buftype
  local bufname = vim.api.nvim_buf_get_name(current_buf)
  bufname = bufname ~= "" and bufname or "[No Name]"

  local ignore_changes = opts.force

  -- Handle special buffer
  local special_buf_config = buf_config.filetypes[filetype] or buf_config.buftypes[buftype]
  if special_buf_config and not special_buf_config.pass then
    if special_buf_config.close_cmd then
      vim.cmd(special_buf_config.close_cmd)
      return
    end
    if #current_win_list > 1 then
      local force = special_buf_config.force or false
      vim.api.nvim_win_close(current_win, force)
      return
    end
  end

  -- Get windows displaying current buffer
  local wins_displaying_current_buf = vim.tbl_filter(function(win)
    return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == current_buf
  end, current_win_list)

  -- Handle modified buffer
  -- When the buffer is displayed in multiple windows, close without write
  if not ignore_changes and vim.bo[current_buf].modified and #wins_displaying_current_buf <= 1 then
    local choice = vim.fn.confirm(
      string.format("Save before closing the buffer? (%s)", bufname), "&Yes\n&No\n&Cancel", 1)
    if choice == 1 then
      vim.cmd("silent! write")
      if vim.bo[current_buf].modified and not is_special_buffer(current_buf) then
        vim.notify(string.format("Failed to save buffer! (%s)", bufname), vim.log.levels.ERROR)
        return
      end
    elseif choice == 2 then
      ignore_changes = true
    else
      return
    end
  end

  -- Prompt for confirmation if terminal has any job running
  if not ignore_changes and buftype == "terminal" then
    if not is_terminal_idle(current_buf) then
      local choice = vim.fn.confirm(
        string.format("Terminal has job running. (%s)", bufname), "&Ignore\n&Cancel", 1)
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
  local remaining_valid_buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and buf ~= current_buf and not is_special_buffer(buf)
  end, vim.api.nvim_list_bufs())

  -- If there will be no valid buffer after closing buffer
  if #remaining_valid_buffers == 0 then
    if #wins_displaying_current_buf > 1 then
      -- If multiple windows showing this last buffer, just close the current window
      -- We don't need to bdelete yet as other windows are holding it
      vim.api.nvim_win_close(current_win, true)
      return
    end
    if opts.quit_on_empty then
      vim.cmd("quitall!")
      return
    end
  end

  -- Select a buffer to switch to after closing current buffer
  local switch_to_buf = select_buffer_to_switch(current_buf, remaining_valid_buffers)
  if not switch_to_buf then
    return
  end

  -- Switch all windows of current buffer to the new buffer
  for _, win in ipairs(wins_displaying_current_buf) do
    vim.api.nvim_win_set_buf(win, switch_to_buf)
  end

  -- Do final buffer close
  local force_close = ignore_changes or buftype == "terminal"
  vim.cmd("silent! bdelete" .. (force_close and "!" or "") .. " " .. current_buf)
  local ok, buflisted = pcall(function()
    return vim.bo[current_buf].buflisted and vim.api.nvim_buf_is_valid(current_buf)
  end)
  if ok and buflisted then
    vim.notify(string.format("Failed to delete buffer! (%s)", bufname), vim.log.levels.ERROR)
  end

  -- Consolidate windows if needed
  if opts.prune_extra_wins then
    consolidate_windows(remaining_valid_buffers)
  end
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
