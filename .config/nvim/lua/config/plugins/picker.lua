return {
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    enabled = false,
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local actionset = require("telescope.actions.set")
      local state = require("telescope.state")
      local builtin = require("telescope.builtin")
      local themes = require("telescope.themes")

      telescope.setup({
        defaults = themes.get_ivy {
          layout_config = {
            height = 0.7,
          },
          mappings = {
            i = {
              ["<ESC>"] = actions.close,
              ["<C-h>"] = "which_key",
              ["<C-n>"] = actions.move_selection_next,
              ["<C-p>"] = actions.move_selection_previous,
              ["<ScrollWheelDown>"] = actions.move_selection_next,
              ["<ScrollWheelUp>"] = actions.move_selection_previous,
              ["<Left>"] = function()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left>", true, false, true), "n", true)
              end,
              ["<Right>"] = function()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), "n", true)
              end,
              ["<C-d>"] = function(prompt_bufnr)
                actionset.scroll_results(prompt_bufnr, 1)
              end,
              ["<C-u>"] = function(prompt_bufnr)
                actionset.scroll_results(prompt_bufnr, -1)
              end,
              ["<C-f>"] = function(prompt_bufnr)
                local results_win = state.get_status(prompt_bufnr).results_win
                local height = vim.api.nvim_win_get_height(results_win)
                actionset.shift_selection(prompt_bufnr, math.floor(height))
              end,
              ["<C-b>"] = function(prompt_bufnr)
                local results_win = state.get_status(prompt_bufnr).results_win
                local height = vim.api.nvim_win_get_height(results_win)
                actionset.shift_selection(prompt_bufnr, -math.floor(height))
              end,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = { "fd", "--hidden", "--no-require-git", "--follow", "--type", "file" },
          },
          live_grep = {
            layout_config = {
              height = 0.95,
            },
          },
          oldfiles = {
            only_cwd = false,
          },
          buffers = {
            only_cwd = false,
            ignore_current_buffer = false,
            sort_mru = true,
          },
          git_files = {
            use_git_root = true,
            show_untracked = true,
          },
          git_status = {
            use_git_root = false,
          },
          diagnostics = {
            severity_limit = "info",
          },
        },
      })

      -- :help telescope.builtin
      local map = vim.keymap.set

      map("n", "<leader>fd", builtin.find_files, { desc = "Telescope: search files in cwd" })
      map("n", "<leader>fr", builtin.oldfiles, { desc = "Telescope: search recent files" })
      map("n", "<leader>fo", builtin.buffers, { desc = "Telescope: search opened buffers" })
      map("n", "<leader>ff", builtin.current_buffer_fuzzy_find, { desc = "Telescope: find in current buffer" })

      map("n", "<leader>gd", function()
        require("config.plugins.telescope.multigrep")({ layout_config = { height = 0.95 } })
      end, { desc = "Telescope: grep in cwd" })
      -- map("n", "<leader>gd", builtin.live_grep, { desc = "Telescope: grep in cwd" })
      map("n", "<leader>gw", function()
        builtin.grep_string({ search = vim.fn.expand("<cword>") })
      end, { desc = "Telescope: grep <cword> in cwd" })
      map("n", "<leader>gW", function()
        builtin.grep_string({ search = vim.fn.expand("<cWORD>") })
      end, { desc = "Telescope: grep <cWORD> in cwd" })

      map("n", "<leader>fp", builtin.git_files, { desc = "Telescope: search git files" })
      map("n", "<leader>gc", builtin.git_commits, { desc = "Telescope: search git commits" })
      map("n", "<leader>gf", builtin.git_bcommits, { desc = "Telescope: search git commits of current file" })
      map("n", "<leader>gb", builtin.git_branches, { desc = "Telescope: search git branches" })
      map("n", "<leader>gg", builtin.git_status, { desc = "Telescope: search git status" })

      map("n", "<leader>sd", builtin.diagnostics, { desc = "Telescope: search diagnostics" })
      map("n", "<leader>ds", function()
        builtin.lsp_document_symbols({ symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module", "Property" } })
      end, { desc = "Fzf: search lsp document symbols" })

      map("n", "<leader>sl", builtin.resume, { desc = "Telescope: resume last search" })

      map("n", "<leader>qf", builtin.quickfix, { desc = "Telescope: search quickfix list" })
      map("n", "<leader>sr", builtin.registers, { desc = "Telescope: search register list" })

      map("n", "<leader>sh", builtin.help_tags, { desc = "Telescope: search help docs" })
      map("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "Telescope: search nvim configs" })
      map("n", "<leader>sp", function()
        builtin.find_files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
      end, { desc = "Telescope: search lazy packages" })
    end,
  },
  {
    "ibhagwan/fzf-lua",
    version = "*",
    enabled = true,
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      local fzf = require("fzf-lua")

      fzf.setup({
        { "ivy" },
        keymap = {
          builtin = {
            ["<C-j>"] = "preview-half-page-down",
            ["<C-k>"] = "preview-half-page-up",
          },
          fzf = {
            ["ctrl-p"] = "up",
            ["ctrl-n"] = "down",
            ["ctrl-q"] = "abort",
            ["ctrl-d"] = "half-page-down",
            ["ctrl-u"] = "half-page-up",
            ["ctrl-f"] = "page-down",
            ["ctrl-b"] = "page-up",
          },
        },
        files = {
          fd_opts = "--type f --hidden --exclude .git --exclude .venv --exclude node_modules",
          previewer = "builtin",
          cwd_prompt = false,
        },
        buffers = {
          sort_lastused = true,
          previewer = "builtin",
        },
        grep = {
          cmd = "rg --line-number --column --no-heading --color=always --smart-case",
          hidden = true,
          rg_glob = true,
          glob_flag = "--iglob",
          glob_separator = "%s%s",
          RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
        },
        fzf_opts = {
          ["--ansi"] = true,
          ["--border"] = "none",
          ["--no-cycle"] = true,
          ["--highlight-line"] = true,
          ["--smart-case"] = true,
        },
        winopts = {
          height = 0.7,
          width = 1.0,
        },
        previewers = {
          builtin = {
            syntax = true,
            treesitter = {
              enabled = true,
              context = false,
            },
          },
        },
        defaults = {
          git_icons = true,
          file_icons = true,
          color_icons = true,
          actions = {
            ["ctrl-q"] = { fn = fzf.actions.file_sel_to_qf, prefix = "select-all" },
          },
        },
      })

      local map = vim.keymap.set

      map("n", "<leader>fd", fzf.files, { desc = "Fzf: search files" })
      map("n", "<leader>fr", fzf.oldfiles, { desc = "Fzf: search recent files" })
      map("n", "<leader>fo", fzf.buffers, { desc = "Fzf: search opened buffers" })
      map("n", "<leader>fm", fzf.marks, { desc = "Fzf: search marks" })
      map("n", "<leader>ff", function()
        fzf.blines({ previewer = false })
      end, { desc = "Fzf: search in current buffer" })

      map("n", "<leader>gd", fzf.live_grep, { desc = "Fzf: grep in cwd" })
      map("n", "<leader>gw", fzf.grep_cword, { desc = "Fzf: search current word" })

      map("n", "<leader>fp", fzf.git_files, { desc = "Fzf: search files in git repo" })
      map("n", "<leader>gc", fzf.git_commits, { desc = "Fzf: search git commits" })
      map("n", "<leader>gf", fzf.git_bcommits, { desc = "Fzf: search git commmits of current file" })
      map("n", "<leader>gb", fzf.git_branches, { desc = "Fzf: search git branches" })
      map("n", "<leader>gg", fzf.git_status, { desc = "Fzf: search git status" })

      map("n", "<leader>sd", fzf.diagnostics_document, { desc = "Fzf: search diagnostics" })
      map("n", "<leader>ds", function()
        fzf.lsp_document_symbols({ symbol_types = { "Class", "Function", "Method", "Constructor", "Interface", "Module", "Property" } })
      end, { desc = "Fzf: search lsp document symbols" })

      map("n", "<leader>sl", fzf.resume, { desc = "Fzf: resume last search" })

      map("n", "<leader>qf", fzf.quickfix, { desc = "Fzf: search quickfix list" })
      map("n", "<leader>sr", fzf.registers, { desc = "Fzf: search register list" })

      map("n", "<leader>sh", fzf.help_tags, { desc = "Fzf: search help" })
      map("n", "<leader>sn", function()
        fzf.files({
          cwd = vim.fn.stdpath("config"),
          fd_opts = "--type f --follow"
        })
      end, { desc = "Fzf: search nvim configs" })
      map("n", "<leader>sp", function()
        fzf.files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
      end, { desc = "Fzf: search lazy packages" })
    end
  },
}
