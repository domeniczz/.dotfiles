return {
  "stevearc/conform.nvim",
  version = "*",
  enabled = false,
  event = "VeryLazy",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        -- lua = { "stylua" },
        python = { "black" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = {
        timeout_ms = 500,
      },
      notify_no_formatters = false,
    })
  end,
}
