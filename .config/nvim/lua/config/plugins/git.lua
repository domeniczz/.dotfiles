return {
  "tpope/vim-fugitive",
  version = "*",
  enabled = true,
  lazy = true,
  keys = {
    { "<leader>gs", "<CMD>Git<CR>", desc = "Fugitive: toggle view" },
  },
  cmd = {
    "G",
    "Git",
    "Gsplit",
    "Gdiffsplit",
    "Gvdiffsplit",
    "Gedit",
    "Gread",
    "Gwrite",
    "Ggrep",
    "GMove",
    "GRename",
    "GDelete",
    "GRemove",
    "GBrowse",
  },
  config = function()
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Fugitive: toggle view" })
  end,
}
