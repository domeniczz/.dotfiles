return {
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    version = "*",
    enabled = true,
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "storm",
        transparent = true,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "transparent",
          floats = "transparent",
        },
        hide_inactive_statusline = true,
        dim_inactive = true,
        lualine_bold = true,
        on_colors = function(colors)
          -- Sets background to none
          colors.bg = "NONE"
        end,
        on_highlights = function(highlights)
          highlights.Normal = { bg = "NONE" }
          highlights.NormalFloat = { bg = "NONE" }
          -- highlights.NormalNC = { bg = "NONE" }
          -- highlights.SignColumn = { bg = "NONE" }
          -- highlights.StatusLine = { bg = "NONE" }
        end,
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    version = "*",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = {
          transparent = true,
          terminal_colors = true,
          hide_nc_statusline = true,
          darken = {
            floats = true,
            sidebars = {
              enable = true,
              list = {},
            },
          },
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
            functions = "NONE",
            variables = "NONE",
            constants = "NONE",
            numbers = "NONE",
            operators = "NONE",
            strings = "NONE",
          },
          hide_end_of_buffer = false,
          dim_inactive = false,
        },
      })
      vim.cmd([[colorscheme github_dark]])
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    version = "*",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
        undercurl = true,
        underline = false,
        bold = true,
        italic = {
          strings = false,
          emphasis = false,
          comments = false,
          operators = false,
          folds = false,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        contrast = "",
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = true,
      })
      vim.cmd([[colorscheme gruvbox]])
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    version = "*",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "auto",
        dark_variant = "main",
        disable_background = true,
        -- disable_float_background = true,
        bold_vert_split = false,
        dim_nc_background = false,
        styles = {
          bold = true,
          italic = true,
          transparency = true,
        },
        highlight_groups = {
          Normal = { bg = "transparent" },
          NormalFloat = { bg = "transparent" },
        },
      })
      vim.cmd([[colorscheme rose-pine]])
    end,
  },
}
