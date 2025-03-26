return {
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    event = "VeryLazy",
    priority = 1000,
    build = ":TSUpdate",
    cmd = {
      "TSUpdateSync",
      "TSUpdate",
      "TSInstall"
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- A list of parser names, or "all"
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "javascript", "html" },
        -- List of parsers to ignore installing (or "all")
        ignore_install = { "latex", "tex" },
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,
        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,
        indent = { enable = true },
        highlight = {
          -- `false` will disable the whole extension
          enable = true,
          use_languagetree = true,
          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
          -- Using this option will slow down your editor, especially when scrolling.
          additional_vim_regex_highlighting = false,
          -- additional_vim_regex_highlighting = { "markdown" },
          disable = function(lang)
            local disabled_languages = {
              latex = true,
            }
            if disabled_languages[lang] then return true end
            -- Disable for large files
            local max_filesize = 200 * 1024
            return require('config.utils').is_current_large_file(
              max_filesize,
              string.format("Treesitter disabled - file larger than %sKB", max_filesize / 1024)
            )
          end,
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
    enabled = true,
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("treesitter-context").setup({
        max_lines = 10,
        min_window_height = 30,
        trim_scope = "outer",
      })
    end
  },
}
