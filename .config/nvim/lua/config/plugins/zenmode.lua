return {
  "folke/zen-mode.nvim",
  enabled = true,
  event = "VeryLazy",
  config = function()
    require("zen-mode").setup({
      window = {
        backdrop = 0.95,
        width = 0.95,
        height = 0.95,
      }
    })
    vim.keymap.set("n", "<leader>wm", function()
      require("zen-mode").toggle()
    end)
  end
}
