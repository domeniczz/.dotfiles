return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    cond = function()
      local max_filesize = vim.g.max_filesize
      local ok, stats = pcall(vim.uv.fs_stat, vim.fn.expand("%"))
      if ok and stats and stats.size > max_filesize then
        return false
      end
      return true
    end,
    config = function()
      -- replaces ensure_installed; async no-op for parsers already installed
      require("nvim-treesitter").install({
        "c",
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "javascript",
        "bash",
        "html",
        "templ",
        "python",
        "rust",
        "latex",
      })

      -- highlighting is now core Neovim: vim.treesitter.start() per filetype.
      -- core ftplugins already start it for lua, markdown and help (vimdoc),
      -- so only start when not already active.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "vim", "javascript", "sh", "bash", "html", "templ", "lua", "markdown", "help", "python", "rust", "tex" },
        callback = function(args)
          local max_filesize = vim.g.max_filesize
          if require("config.utils").is_current_large_file(
            max_filesize,
            string.format("Treesitter disabled - file larger than %sKB", max_filesize / 1024)
          ) then
            -- also stops the highlighter core ftplugins may have started
            pcall(vim.treesitter.stop)
            return
          end
          -- Treesitter tokenizes whole lines (ignores synmaxcol), so a single long line stalls scroll/redraw
          local line_max_col = 400
          if require("config.utils").has_long_line(line_max_col) then
            pcall(vim.treesitter.stop)
            vim.notify(
              string.format("Treesitter disabled - line longer than %d chars", line_max_col),
              vim.log.levels.WARN,
              { title = "Long Line" }
            )
            return
          end
          if not vim.b[args.buf].ts_highlight then
            -- pcall so a missing/still-installing parser falls back to regex syntax
            pcall(vim.treesitter.start)
          end
        end,
      })

      -- Set fold method to use treesitter expression
      -- vim.opt.foldmethod = "expr"
      -- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    version = "*",
    enabled = true,
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
      "TSContext",
    },
    config = function()
      require("treesitter-context").setup({
        max_lines = 10,
        min_window_height = 30,
        trim_scope = "outer",
        mode = 'cursor',
      })
    end
  },
}
