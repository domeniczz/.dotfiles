return {
  'stevearc/aerial.nvim',
  enabled = true,
  -- event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>A", "<CMD>AerialToggle!<CR>", desc = "Aerial: toggle view" },
  },
  config = function()
    require("aerial").setup({
      backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
      layout = {
        max_width = { 40, 0.2 },
        min_width = 30,
        default_direction = "prefer_left",
        resize_to_content = true,
      },
      close_automatic_events = {},

      lazy_load = true,
      -- Disable aerial on files with this many lines
      disable_max_lines = 10000,
      -- Disable aerial on files this size or larger (in bytes)
      disable_max_size = 2000000,

      highlight_on_jump = 200,
      manage_folds = true,
      link_folds_to_tree = false,
      link_tree_to_folds = true,
      post_jump_cmd = "normal! zz",
      show_guides = true,
      -- Set when aerial has attached to a buffer
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set("n", "{", "<CMD>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "}", "<CMD>AerialNext<CR>", { buffer = bufnr })
      end,
    })
    vim.keymap.set("n", "<leader>A", "<CMD>AerialToggle!<CR>", { desc = "Aerial: toggle view" })
  end,
}
