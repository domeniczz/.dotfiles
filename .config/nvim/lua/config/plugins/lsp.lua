return {
  -- lsp progress messages
  {
    "j-hui/fidget.nvim",
    enabled = true,
    event = "LspAttach",
    config = function()
      require("fidget").setup({
        notification = {
          window = {
            winblend = 0,
          },
        },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    enabled = true,
    -- event = {"BufReadPre", "BufNewFile"},
    ft = { "lua", "python", "rust" },
    dependencies = {
      "saghen/blink.cmp",
      -- "hrsh7th/cmp-nvim-lsp",
    },
    -- init = function()
    --   local max_filesize = 5120 * 1024
    --   if require('config.utils').is_current_large_file(max_filesize, string.format("LSP disabled - file larger than %sKB", max_filesize / 1024)) then
    --     vim.b.lsp_enabled = false
    --     return
    --   end
    -- end,
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      -- local capabilities = require('cmp_nvim_lsp').default_capabilities()

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          local map = vim.keymap.set
          map("n", "K", "<CMD>lua vim.lsp.buf.hover()<cr>", opts)
          map("n", "gd", "<CMD>lua vim.lsp.buf.definition()<cr>", opts)
          map("n", "gD", "<CMD>lua vim.lsp.buf.declaration()<cr>", opts)
          map("n", "gi", "<CMD>lua vim.lsp.buf.implementation()<cr>", opts)
          map("n", "go", "<CMD>lua vim.lsp.buf.type_definition()<cr>", opts)
          map("n", "gr", "<CMD>lua vim.lsp.buf.references()<cr>", opts)
          map("n", "gs", "<CMD>lua vim.lsp.buf.signature_help()<cr>", opts)
          map("n", "<F2>", "<CMD>lua vim.lsp.buf.rename()<cr>", opts)
          map({ "n", "x" }, "<F3>", "<CMD>lua vim.lsp.buf.format({async = true})<cr>", opts)
          map("n", "<F4>", "<CMD>lua vim.lsp.buf.code_action()<cr>", opts)
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP format on write",
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({
                  async = false,
                  timeout_ms = 500,
                  bufnr = args.buf,
                  id = client.id,
                })
              end
            })
          end
        end
      })

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_lines = {
          current_line = true
        },
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      vim.lsp.set_log_level("ERROR")

      local lspconfig = require("lspconfig")

      lspconfig.lua_ls.setup({
        autostart = false,
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim", "bit", "it", "describe", "before_each", "after_each" },
              disable = { "undefined-field", "undefined-global", "duplicate-set-field" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      lspconfig.pyright.setup({
        autostart = false,
        capabilities = capabilities,
      })


      lspconfig.rust_analyzer.setup({
        autostart = false,
        capabilities = capabilities,
      })
    end,
  },
}
