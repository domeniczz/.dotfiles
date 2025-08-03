return {
  "lervag/vimtex",
  version = "*",
  enabled = true,
  cmd = {
    "VimtexInverseSearch"
  },
  ft = {
    "tex"
  },
  config = function()
    local opt = vim.g
    opt.vimtex_syntax_enabled = 0
    opt.vimtex_quickfix_enabled = 1
    opt.vimtex_quickfix_autojump = 0
    opt.vimtex_quickfix_mode = 1
    opt.vimtex_quickfix_open_on_warning = 1
    opt.vimtex_view_method = "zathura"
    opt.vimtex_view_forward_search_on_start = 1
    opt.vimtex_compiler_method = "latexmk"
    opt.vimtex_compiler_latexmk = {
      build_dir = "",
      callback = 1,
      continuous = 1,
      executable = "latexmk",
      options = {
        "-pdf",
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-shell-escape",
      },
    }

    vim.keymap.set("n", "<leader>lc", "<CMD>VimtexCompile<CR>", { buffer = true, silent = true, desc = "Vimtex: compile" })
    vim.keymap.set("n", "<leader>lv", "<CMD>VimtexView<CR>", { buffer = true, silent = true, desc = "Vimtex: open in viewer" })
    vim.keymap.set("n", "g<C-g>", "<CMD>VimtexCountWords<CR>", { buffer = true, silent = true, desc = "Vimtex: word count" })
  end,
}
