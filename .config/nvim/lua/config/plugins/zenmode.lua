return {
  "folke/zen-mode.nvim",
  version = "*",
  enabled = true,
  lazy = true,
  keys = {
    { "<leader>zm", "<CMD>ZenMode<CR>", desc = "Zenmode: toggle zen mode" },
  },
  cmd = {
    "ZenMode",
  },
  config = function()
    require("zen-mode").setup({
      window = {
        backdrop = 0.95,
        width = 0.95,
        height = 0.95,
      }
    })
    vim.keymap.set("n", "<leader>zm", "<CMD>ZenMode<CR>", { desc = "Zenmode: toggle zen mode" })
  end
}
