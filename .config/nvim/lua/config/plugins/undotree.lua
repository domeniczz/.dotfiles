return {
  "mbbill/undotree",
  branch = "master",
  lazy = false,
  config = function()
    vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = "Toggle undotree view"})
  end,
}
