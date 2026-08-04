return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    cond = function()
      local max_filesize = vim.g.max_filesize
      local ok, stats = pcall(vim.loop.fs_stat, vim.fn.expand("%"))
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
      })

      -- highlighting is now core Neovim: vim.treesitter.start() per filetype.
      -- core ftplugins already start it for lua, markdown and help (vimdoc),
      -- so only start when not already active.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "vim", "javascript", "sh", "bash", "html", "templ", "lua", "markdown", "help" },
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
          if not vim.b[args.buf].ts_highlight then
            vim.treesitter.start()
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
