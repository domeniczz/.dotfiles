return {
  "mbbill/undotree",
  enabled = true,
  -- event = "VeryLazy",
  keys = {
    { "<leader>u", "<CMD>UndotreeToggle<CR>", desc = "Undotree: toggle view" },
  },
  cmd = {
    "UndotreeToggle",
    "UndotreeShow",
    "UndotreeHide",
  },
  config = function()
    vim.g.undotree_SetFocusWhenToggle = 1
    local map = vim.keymap.set
    map("n", "<leader>u", "<CMD>UndotreeToggle<CR>", { desc = "Undotree: toggle view" })
    vim.g.Undotree_CustomMap = function()
      map("n", "J", "<PLUG>UndotreePreviousState", { buffer = true, desc = "Undotree: previous state" })
      map("n", "K", "<PLUG>UndotreeNextState", { buffer = true, desc = "Undotree: next state" })
      map("n", "<CR>", "<PLUG>UndotreeFocusTarget", { buffer = true, desc = "Undotree: focus target" })
      map("n", "Y", "<PLUG>UndotreeEnter", { buffer = true, desc = "Undotree: enter state" })
    end
  end,
}
