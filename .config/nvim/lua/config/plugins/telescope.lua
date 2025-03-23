return {
  "nvim-telescope/telescope.nvim",
  enabled = true,
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local actions = require("telescope.actions")
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = { theme = "ivy", layout_config = { height = 0.8 } },
        git_files = { theme = "ivy", layout_config = { height = 0.8 } },
        live_grep = { theme = "ivy", layout_config = { height = 0.8 } },
        grep_string = { theme = "ivy", layout_config = { height = 0.8 } },
        help_tags = { theme = "ivy", layout_config = { height = 0.8 } },
        oldfiles = { theme = "ivy", layout_config = { height = 0.8 } },
        buffers = { theme = "ivy", layout_config = { height = 0.8 } },
      },
      extensions = {
        wrap_results = true,
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
        fzf = {},
      },
    })
    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")

    -- :help telescope.builtin
    local builtin = require("telescope.builtin")
    local themes = require("telescope.themes")
    local map = vim.keymap.set

    map("n", "<leader>fd", function()
      builtin.find_files({ find_command = { "fd", "--hidden", "--no-require-git", "--follow", "--type", "file" } })
      -- builtin.find_files({ find_command = { "rg", "--files", "--hidden", "--no-require-git", "--smart-case", "--follow" } })
    end, { desc = "Search file in cwd" })
    map("n", "<C-p>", function() builtin.git_files({ use_git_root = true, show_untracked = true }) end, { desc = "Search git files" })
    map("n", "<leader>fr", function() builtin.oldfiles({ only_cwd = false }) end, { desc = "Search recent files" })
    map("n", "<leader>fo", function()
      builtin.buffers({ only_cwd = false, ignore_current_buffer = false, sort_mru = true })
    end, { desc = "Search opened buffers" })
    -- map("n", "<leader>ff", function() builtin.current_buffer_fuzzy_find({}) end, { desc = "Find in current buffer" })

    map("n", "<leader>gd", function()
      require("config.plugins.telescope.multigrep")(themes.get_ivy({ layout_config = { height = 0.8 } }))
    end, { desc = "Grep content within cwd" })
    -- map("n", "<leader>gd", function() builtin.live_grep() end)

    map("n", "<leader>ws", function()
      local word = vim.fn.expand("<cword>")
      builtin.grep_string({ search = word })
    end)
    map("n", "<leader>Ws", function()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search = word })
    end)

    map("n", "<leader>en", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config"):gsub("(/home/[^/]+)", "%1/.dotfiles") })
    end, { desc = "Search within nvim config" })
    map("n", "<leader>ep", function()
      builtin.find_files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
    end, { desc = "Search within lazy packages" })
    map("n", "<leader>vh", builtin.help_tags, {})

    map("n", "<leader>fA", function()
      telescope.extensions.aerial.aerial()
    end, { desc = "Search outline symbols with aerial" })
  end,
}
