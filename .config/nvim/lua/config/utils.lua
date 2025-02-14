function _G.get_current_file_size()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then return 0, false end
  local ok, stats = pcall(vim.loop.fs_stat, vim.fn.expand("%"))
  if ok and stats then return stats.size, true end
  return 0, false
end

function _G.is_current_large_file(max_filesize, prompt)
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

function _G.kill_buffer_or_close_window()
  if vim.fn.getcmdwintype() ~= "" then return vim.cmd("quit") end

  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()

  if vim.bo[current_buf].buftype == "terminal" or vim.bo[current_buf].filetype == "terminal" then
    return vim.api.nvim_buf_delete(current_buf, { force = true })
  end

  local clients = vim.lsp.get_clients({ bufnr = current_buf })
  for _, client in ipairs(clients) do
    vim.lsp.buf_detach_client(current_buf, client.id)
  end

  local windows_count_of_current_buffer = #vim.fn.win_findbuf(current_buf)
  if windows_count_of_current_buffer > 1 then
    return vim.api.nvim_win_close(current_win, false)
  end

  local has_valid_buffer = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and buf ~= current_buf then
      has_valid_buffer = true
      break
    end
  end
  local should_quit = not has_valid_buffer

  local buf_to_close_directly = {
    undotree = true,
    fugitive = true,
    netrw = true,
  }
  local buf_ft = vim.bo[current_buf].filetype
  if buf_to_close_directly[buf_ft] then
    vim.api.nvim_buf_delete(current_buf, { force = false })
    return
  elseif buf_ft == "harpoon" then
    vim.api.nvim_buf_delete(current_buf, { force = true })
    return
  end

  if vim.bo[current_buf].modified then
    local choice = vim.fn.confirm("Buffer has unsaved changes. Save before closing?", "&Yes\n&No\n&Cancel", 1)
    if choice == 1 then
      local filename = ""
      if vim.fn.bufname(current_buf) == "" then
        local filename = vim.fn.input("Enter file name to save: ")
        if filename == "" then return end
      end
      local success, err = pcall(vim.cmd, "silent! write " .. vim.fn.fnameescape(filename))
      if success then
        vim.api.nvim_buf_delete(current_buf, { force = false })
      else
        return vim.api.nvim_err_writeln("Failed to save buffer: " .. tostring(err))
      end
    elseif choice == 2 then
      vim.api.nvim_buf_delete(current_buf, { force = true })
    else
      return
    end
  else
    vim.api.nvim_buf_delete(current_buf, { force = false })
  end

  if should_quit then vim.cmd("quit") end
end
