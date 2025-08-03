return {
  "stevearc/aerial.nvim",
  version = "*",
  enabled = true,
  lazy = true,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>A", "<CMD>AerialToggle<CR>", desc = "Aerial: toggle view" },
    { "<leader>}", "<CMD>AerialNext<CR>", desc = "Aerial: jump to next symbol" },
    { "<leader>{", "<CMD>AerialPrev<CR>", desc = "Aerial: jump to prev symbol" },
  },
  cmd = {
    "AerialToggle",
    "AerialOpen",
    "AerialOpenAll",
    "AerialNavToggle",
    "AerialNavOpen",
    "AerialGo",
    "AerialNext",
    "AerialPrev",
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
        vim.keymap.set("n", "<leader>}", "<CMD>AerialNext<CR>", { buffer = bufnr, desc = "Aerial: jump to next symbol" })
        vim.keymap.set("n", "<leader>{", "<CMD>AerialPrev<CR>", { buffer = bufnr, desc = "Aerial: jump to prev symbol" })
      end,
    })
    vim.keymap.set("n", "<leader>A", "<CMD>AerialToggle<CR>", { desc = "Aerial: toggle view" })

    vim.keymap.set("n", "<leader>fA", function()
      require("telescope").extensions.aerial.aerial()
    end, { desc = "Telescope: search outline symbols" })
  end,
}
