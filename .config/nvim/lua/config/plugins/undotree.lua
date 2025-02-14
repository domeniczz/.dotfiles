return {
  "mbbill/undotree",
  enabled = true,
  -- event = "VeryLazy",
  keys = {
    { "<leader>u", "<CMD>UndotreeToggle<CR>", desc = "undotree: toggle view" },
  },
  config = function()
    vim.keymap.set("n", "<leader>u", "<CMD>UndotreeToggle<CR>", { desc = "undotree: toggle view" })
  end,
}
