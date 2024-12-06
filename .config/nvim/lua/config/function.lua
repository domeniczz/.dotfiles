-- Clear all registers
function _G.clear_registers()
  -- Define all registers to clear
  local registers = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"*+'
  
  -- Clear each register
  for i = 1, #registers do
    local reg = registers:sub(i,i)
    -- Set each register to empty string
    vim.fn.setreg(reg, vim.fn.getreg('_'))  -- assign the value to be black hole register
    -- vim.fn.setreg(reg, {})
  end

  -- Print a confirmation message
  print("All registers cleared!")
end

-- Create a command to call the function
vim.api.nvim_create_user_command('Clearregs', clear_registers, {})

-- Create a key mapping (e.g., <leader>cr)
-- vim.keymap.set('n', '<leader>cr', clear_registers, { noremap = true, silent = true, desc = 'Clear all registers' })
