return {
  "lervag/vimtex",
  lazy = false,
  -- tag = "v2.15", -- uncomment to pin to a specific release
  config = function()
    vim.api.nvim_create_autocmd({"FileType"}, {
      pattern = {"tex", "latex"},
      callback = function()
        vim.cmd('syntax enable')
        vim.cmd('syntax on')
      end,
    })

    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_syntax_enabled = 1
    vim.g.vimtex_syntax_legacy = 0

    vim.g.vimtex_compiler_latexmk = {
      build_dir = '',
      callback = 1,
      continuous = 1,
      executable = 'latexmk',
      options = {
        '-pdf',
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
      }
    }

    -- Complile the tex file
    -- vim.keymap.set('n', '<leader>lc', ':w<CR>:!latexmk -pdf -interaction=nonstopmode -synctex=1 %<CR>', { remap = false, silent = true })
    vim.keymap.set('n', '<Leader>lc', function()
      -- Save the current buffer
      -- vim.cmd('write')
      local save_success = pcall(vim.cmd, 'write')
        if not save_success then
          vim.notify('Failed to save the file', vim.log.levels.ERROR)
        return
      end
      
      -- Get the current file path and derive PDF path
      local tex_file = vim.fn.expand('%')
      local pdf_file = tex_file:gsub('%.tex$', '.pdf')
      local escaped_pdf = vim.fn.shellescape(pdf_file)
      
      -- Compile with latexmk
      local compile_cmd = string.format('latexmk -pdf -interaction=nonstopmode -synctex=1 %s > /dev/null 2>&1', vim.fn.shellescape(tex_file))
      local compile_status = os.execute(compile_cmd)
      
      -- If compilation successful, open PDF
      if compile_status == 0 then
        local open_cmd = string.format('xdg-open %s &', escaped_pdf)
        os.execute(open_cmd)
      else
        vim.notify('LaTeX compilation failed', vim.log.levels.ERROR)
      end
    end, { remap = false, silent = true })

    -- Open the pdf file without compile
    vim.keymap.set('n', '<Leader>lr', function()
      -- Derive PDF path from current buffer
      local tex_file = vim.fn.expand('%')
      local pdf_file = tex_file:gsub('%.tex$', '.pdf')
      
      -- Verify PDF existence
      if vim.fn.filereadable(pdf_file) == 0 then
        vim.notify('PDF file does not exist: ' .. pdf_file, vim.log.levels.ERROR)
        return
      end
      
      -- Execute command with error handling
      local escaped_pdf = vim.fn.shellescape(pdf_file)
      local open_cmd = string.format('xdg-open %s &', escaped_pdf)
      local execute_status = os.execute(open_cmd)
      if execute_status ~= 0 then
        vim.notify('Failed to open PDF viewer', vim.log.levels.ERROR)
      end
    end, { remap = false, silent = true })

    -- Forward synctex: jump from source to relative position in pdf
    vim.keymap.set('n', '<leader>lg', function()
      local line = vim.fn.line('.')
      local col = vim.fn.col('.')
      local tex_file = vim.fn.expand('%:p')
      local pdf_file = tex_file:gsub('%.tex$', '.pdf')
      
      local cmd = string.format(
        'zathura --synctex-forward %d:%d:%s %s',
        line,
        col,
        tex_file,
        pdf_file
      )
      
      vim.fn.system(cmd)
    end, { silent = true, buffer = true })

  end
}
