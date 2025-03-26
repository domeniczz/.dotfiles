return {
  {
    "mbbill/undotree",
    enabled = true,
    -- event = "VeryLazy",
    keys = {
      { "<leader>u", "<CMD>UndotreeToggle<CR>", desc = "Undotree: toggle view" },
    },
    config = function()
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.keymap.set("n", "<leader>u", "<CMD>UndotreeToggle<CR>", { desc = "Undotree: toggle view" })
    end,
  },
}
