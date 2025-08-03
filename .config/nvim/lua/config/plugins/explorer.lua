return {
  {
    "stevearc/oil.nvim",
    version = "*",
    enabled = true,
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local oil = require("oil")
      oil.setup {
        columns = {
          "icon",
        },
        buf_options = {
          buflisted = false,
          bufhidden = "hide",
        },
        view_options = {
          show_hidden = true,
          -- is_always_hidden = function(name, _)
          --   local folder_skip = { ".git" }
          --   return vim.tbl_contains(folder_skip, name)
          -- end,
        },
        constrain_cursor = "editable",
        watch_for_changes = true,
        keymaps = {
          ["g?"] = { "actions.show_help", mode = "n" },
          ["<CR>"] ={ "actions.select", mode = "n" },
          ["<C-s>"] = { "actions.select", opts = { vertical = true }, mode = "n" },
          ["<C-h>"] = { "actions.select", opts = { horizontal = true }, mode = "n" },
          ["<C-t>"] = { "actions.select", opts = { tab = true }, mode = "n" },
          ["<C-p>"] = { "actions.preview", mode = "n" },
          ["<C-c>"] = { "actions.close", mode = "n" },
          ["<C-l>"] = { "actions.refresh", mode = "n" },
          ["H"] = { "actions.parent", mode = "n" },
          ["L"] = { "actions.select", mode = "n" },
          ["J"] = { "j", mode = "n" },
          ["K"] = { "k", mode = "n" },
          ["_"] = { "actions.open_cwd", mode = "n" },
          ["`"] = { "actions.cd", mode = "n" },
          ["gs"] = { "actions.change_sort", mode = "n" },
          ["gx"] = { "actions.open_external", mode = "n" },
          ["g."] = { "actions.toggle_hidden", mode = "n" },
          ["g\\"] = { "actions.toggle_trash", mode = "n" },
        },
        delete_to_trash = false,
        cleanup_delay_ms = 0,
      }
      vim.keymap.set("n", "<leader>-", "<CMD>Oil<CR>", { desc = "Oil: open cwd" })
      -- vim.keymap.set("n", "<leader>=", oil.toggle_float, { desc = "Open cwd in float window" })
    end,
  },
  {
    "vifm/vifm.vim",
    version = "*",
    enabled = true,
    lazy = true,
    cmd = {
      "Vifm",
      "EditVifm",
      "SplitVifm",
      "VsplitVifm",
      "DiffVifm",
      "TabVifm",
    },
    config = function()
      vim.keymap.set("n", "<leader>vi", "<CMD>Vifm<CR>", { desc = "Vifm: toggle view" })
    end,
  },
}
