local usercmd = vim.api.nvim_create_user_command

usercmd("Clearregs", function()
  local registers = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"*+'
  for i = 1, #registers do
    local reg = registers:sub(i, i)
    vim.fn.setreg(reg, vim.fn.getreg("_"))
  end
  print("All registers cleared!")
end, { desc = "clear all registers" })

usercmd("Ypwd", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "yank absolute path of current buffer" })

usercmd("W", function()
  require("config.utils").sudo_write()
end, {bang = true})
