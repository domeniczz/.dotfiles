return {
  "vifm/vifm.vim",
  enabled = true,
  lazy = true,
  cmd = {
    "Vifm",
    "EditVifm",
    "SplitVifm",
    "VsplitVifm",
    "DiffVifm",
    "TabVifm"
  },
  config = function()
    vim.keymap.set("n", "<leader>v", "<CMD>EditVifm<CR>", { desc = "Vifm: toggle view" })
  end,
}
