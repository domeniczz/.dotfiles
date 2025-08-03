return {
  "OXY2DEV/markview.nvim",
  version = "*",
  enabled = true,
  lazy = true,
  keys = {
    { "<leader>mv", "<CMD>Markview attach<CR>", desc = "Markview: attach preview for buffer" },
  },
  cmd = {
    "Markview",
  },
  config = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "MarkviewAttach",
      callback = function(event)
        require("markview").setup({
          preview = {
            enable = false,
          },
        })
        vim.keymap.set("n", "<leader>mv", "<CMD>Markview toggle<CR>", { desc = "Markview: toggle preview for buffer" })
      end
    })
  end,
}
