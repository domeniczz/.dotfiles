return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    enabled = true,
    event = "VeryLazy",
    priority = 1000,
    build = ":TSUpdate",
    cmd = {
      "TSInstall",
      "TSUpdate",
      "TSUpdateSync",
    },
    cond = function()
      local max_filesize = vim.g.max_filesize
      local ok, stats = pcall(vim.loop.fs_stat, vim.fn.expand("%"))
      if ok and stats and stats.size > max_filesize then
        return false
      end
      return true
    end,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "javascript", "bash", "html" },
        ignore_install = { "latex" },
        sync_install = false,
        auto_install = true,
        indent = {
          enable = true,
        },
        highlight = {
          enable = true,
          use_languagetree = true,
          additional_vim_regex_highlighting = false,
          disable = function(lang)
            local disabled_languages = {
              latex = true,
            }
            if disabled_languages[lang] then return true end
            local max_filesize = vim.g.max_filesize
            return require('config.utils').is_current_large_file(
              max_filesize,
              string.format("Treesitter disabled - file larger than %sKB", max_filesize / 1024)
            )
          end,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = false,
          keymaps = {
            init_selection = "<CR>",
            scope_incremental = "<CR>",
            node_incremental = "<CR>",
            node_decremental = "<BS>",
          },
        },
      })

      local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      treesitter_parser_config.templ = {
        install_info = {
          url = "https://github.com/vrischmann/tree-sitter-templ.git",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "master",
        },
      }
      vim.treesitter.language.register("templ", "templ")

      -- Set fold method to use treesitter expression
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
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
