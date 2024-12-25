return {
  "nvim-telescope/telescope.nvim",
  branch = '0.1.x',
  dependencies = {
    "nvim-lua/plenary.nvim"
  },
  -- [[ Configure Telescope ]]
  -- See `:help telescope` and `:help telescope.setup()`
  config = function()
    local actions = require("telescope.actions")
    require('telescope').setup({
      defaults = {
        mappings = {
          -- Exit telescope with single Esc
          i = {
            ["<esc>"] = actions.close,
          },
        },
      },
      -- defaults = {
      --   -- See `:help telescope.setup()`
      --   layout_config = {
      --     prompt_position = "top",
      --     preview_cutoff = 120,
      --     horizontal = {
      --       preview_width = 0.55,
      --     },
      --     vertical = {
      --       preview_height = 0.5,
      --     },
      --   },
      --   sorting_strategy = "ascending",
      --   mappings = {
      --     i = {
      --       ["<esc>"] = require('telescope.actions').close,
      --       ["<C-j>"] = require('telescope.actions').move_selection_next,
      --       ["<C-k>"] = require('telescope.actions').move_selection_previous,
      --     },
      --   },
      -- },
      -- pickers = {
      --   find_files = {
      --     hidden = true,
      --   },
      --   git_files = {
      --     hidden = true,
      --   },
      --   grep_string = {
      --     search = "",
      --     only_sort_text = true,
      --   },
      -- },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    })

    -- See `:help telescope.builtin`
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>f', builtin.find_files, {})
    vim.keymap.set('n', '<C-p>', builtin.git_files, {})
    vim.keymap.set('n', '<leader>ws', function()
      local word = vim.fn.expand("<cword>")
      builtin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>Ws', function()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search = word })
    end)
    vim.keymap.set('n', '<leader>sp', function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end)
    vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
  end
}
