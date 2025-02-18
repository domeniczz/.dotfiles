return {
  {
    "mbbill/undotree",
    enabled = true,
    -- event = "VeryLazy",
    keys = {
      { "<leader>u", "<CMD>UndotreeToggle<CR>", desc = "undotree: toggle view" },
    },
    config = function()
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.keymap.set("n", "<leader>u", "<CMD>UndotreeToggle<CR>", { desc = "undotree: toggle view" })
    end,
  },
  {
    "debugloop/telescope-undo.nvim",
    enable = false,
    dependencies = {
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    keys = {
      { "<leader>U", "<CMD>Telescope undo<CR>", desc = "undo history" },
    },
    config = function()
      require("telescope").setup({
        extensions = {
          undo = {
            use_delta = true,
            side_by_side = true,
            theme = "ivy",
            layout_config = {
              height = 0.8,
            },
          },
        },
      })
      require("telescope").load_extension("undo")
    end
  },
}
