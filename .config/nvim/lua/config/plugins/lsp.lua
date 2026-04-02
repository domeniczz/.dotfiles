return {
  -- lsp progress messages
  {
    "j-hui/fidget.nvim",
    version = "*",
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
    version = "*",
    enabled = true,
    ft = {
      "lua",
      "python",
      "rust",
    },
    dependencies = {
      "saghen/blink.cmp",
      -- "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      -- local capabilities = require("cmp_nvim_lsp").default_capabilities()

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
                })
              end
            })
          end
        end
      })

      vim.diagnostic.config({
        virtual_text = true,
        -- virtual_lines = {
        --   current_line = true,
        -- },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
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

      -- Use vim.lsp.config() to define configs (nvim-lspconfig provides defaults)
      vim.lsp.config("lua_ls", {
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

      vim.lsp.config("pyright", {
        capabilities = capabilities,
      })

      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
      })

      local servers = {
        "lua_ls",
        "pyright",
        "rust_analyzer",
      }

      vim.api.nvim_create_user_command("LspStart", function()
        vim.lsp.enable(servers)
      end, { desc = "Enable LSP servers" })

      vim.api.nvim_create_user_command("LspStop", function()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          vim.lsp.enable(client.name, false)
          client:stop(2000)
        end
      end, { desc = "Stop LSP servers" })

      vim.api.nvim_create_user_command("LspRestart", function()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          vim.lsp.enable(client.name, false)
          vim.lsp.enable(client.name)
        end
      end, { desc = "Restart LSP servers" })
    end,
  },
}
