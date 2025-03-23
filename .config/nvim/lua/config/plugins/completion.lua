return {
  {
    "saghen/blink.cmp",
    version = "*",
    enabled = true,
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            fallbacks = { "buffer" },
            enabled = true,
            async = false,
            timeout_ms = 3000,
          },
          cmdline = {
            name = "Cmdline",
            module = "blink.cmp.sources.cmdline",
            min_keyword_length = 2,
          },
          buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
            min_keyword_length = 1,
            opts = {
              -- default to all visible buffers
              get_bufnrs = function()
                return vim
                  .iter(vim.api.nvim_list_wins())
                  :map(function(win)
                    return vim.api.nvim_win_get_buf(win)
                  end)
                  :filter(function(buf)
                    return vim.bo[buf].buftype ~= "nofile"
                  end)
                  :totable()
              end,
            },
          },
        },
      },
      completion = {
        list = {
          max_items = 100,
          selection = {
            auto_insert = true,
            preselect = true,
          },
          cycle = {
            from_bottom = true,
            from_top = false,
          },
        },
        accept = {
          auto_brackets = {
            enabled = true,
            default_brackets = { "{", "}" },
          },
        },
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 500,
          treesitter_highlighting = true,
          window = { border = "rounded" },
        },
        menu = {
          enabled = true,
          border = "none",
          scrollbar = true,
        },
        -- ghost_text = {
        --   enabled = true,
        -- },
      },
      keymap = {
        preset = "default",
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },
      cmdline = {
        keymap = {
          preset = "cmdline",
          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
        },
        completion = {
          menu = {
            auto_show = false,
          },
        },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    version = "*",
    enabled = false,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require("cmp")
      local cmp_select = { behavior = cmp.SelectBehavior.Select }
      cmp.setup({
        performance = {
          debounce = 0,
          throttle = 0,
          max_view_entries = 10,
        },
        completion = {
          keyword_length = 2,
          completeopt = "menu,menuone,noinsert",
        },
        sources = {
          { name = "nvim_lsp", priority = 1000 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
          ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-space>"] = cmp.mapping.complete(),
        }),
        -- snippet = {
        --   expand = function(args)
        --     vim.snippet.expand(args.body)
        --   end,
        -- },
        enabled = function()
          local context = require("cmp.config.context")
          if vim.api.nvim_get_mode().mode == "c" then
            return true
          else
            return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
          end
        end,
      })
    end,
  },
}
