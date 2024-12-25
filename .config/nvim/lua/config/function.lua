-- Clear all registers
function _G.clear_registers()
  local registers = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"*+'
  for i = 1, #registers do
    local reg = registers:sub(i,i)
    vim.fn.setreg(reg, vim.fn.getreg('_'))  -- assign the value to be black hole register
    -- vim.fn.setreg(reg, {})
  end
  print("All registers cleared!")
end

vim.api.nvim_create_user_command('Clearregs', clear_registers, {})
-- vim.keymap.set('n', '<leader>cr', clear_registers, { noremap = true, silent = true, desc = 'Clear all registers' })
