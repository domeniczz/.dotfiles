return {
  "tpope/vim-fugitive",
  branch = "master",
  lazy = true,
  config = function()
    vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { desc = "Toggle git view"})
  end,
}
