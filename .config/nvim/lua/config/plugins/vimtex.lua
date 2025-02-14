return {
  "lervag/vimtex",
  enabled = true,
  lazy = true,
  keys = {
    { "<leader>lc", "<CMD>VimtexCompile<CR>", desc = "vimtex: compile" },
    { "<leader>lr", "<CMD>VimtexView<CR>", desc = "vimtex: view pdf" },
  },
  config = function()
    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = { "tex", "latex" },
      callback = function()
        vim.cmd("syntax enable")
        vim.cmd("syntax on")
      end,
    })

    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_syntax_enabled = 1
    vim.g.vimtex_syntax_legacy = 0
    vim.g.vimtex_compiler_latexmk = {
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

    -- Complile the tex file
    vim.keymap.set("n", "<leader>lc", function()
      local save_success = pcall(vim.cmd, "write")
      if not save_success then
        vim.notify("Failed to save the file", vim.log.levels.ERROR)
        return
      end
      local tex_file_path = vim.fn.expand("%")
      local pdf_file_path = tex_file_path:gsub("%.tex$", ".pdf")
      local compile_cmd = string.format(
        "latexmk -pdf -interaction=nonstopmode -synctex=1 %s > /dev/null 2>&1",
        vim.fn.shellescape(tex_file_path)
      )
      local compile_status = os.execute(compile_cmd)
      if compile_status == 0 then
        vim.fn.jobstart(string.format("xdg-open %s &", vim.fn.shellescape(pdf_file_path)))
      else
        vim.notify("LaTeX compilation failed", vim.log.levels.ERROR)
      end
    end, { remap = false, silent = true })

    -- Open the pdf file without compile
    vim.keymap.set("n", "<leader>lr", function()
      local pdf_file_path = vim.fn.expand("%"):gsub("%.tex$", ".pdf")
      if vim.fn.filereadable(pdf_file_path) == 0 then
        vim.notify("PDF file does not exist: " .. pdf_file_path, vim.log.levels.ERROR)
        return
      end
      vim.fn.jobstart(string.format("xdg-open %s", vim.fn.shellescape(pdf_file_path)))
    end, { remap = false, silent = true })

    -- Forward synctex: jump from source to relative position in pdf
    vim.keymap.set("n", "<leader>lg", function()
      local line = vim.fn.line(".")
      local col = vim.fn.col(".")
      local tex_file_path = vim.fn.expand("%:p")
      local pdf_file_path = tex_file_path:gsub("%.tex$", ".pdf")

      local cmd = string.format("zathura --synctex-forward %d:%d:%s %s", line, col, tex_file_path, pdf_file_path)
      vim.fn.jobstart(cmd)
    end, { silent = true, buffer = true })
  end,
}
