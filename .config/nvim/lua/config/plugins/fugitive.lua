return {
  "tpope/vim-fugitive",
  enabled = true,
  -- event = "VeryLazy",
  lazy = true,
  keys = {
    { "<leader>gs", "<CMD>Git<CR>", desc = "fugitive: toggle git view" },
  },
  cmd = {
    "Gdiffsplit",
    "Gvdiffsplit",
  },
  config = function()
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Toggle git view" })
  end,
}
