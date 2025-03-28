return {
  "ThePrimeagen/harpoon",
  enabled = true,
  branch = "harpoon2",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- "nvim-telescope/telescope.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    })

    -- -- Configure harpoon to use telescope ui
    -- local conf = require("telescope.config").values
    -- local function toggle_telescope(harpoon_files)
    --   local file_paths = {}
    --   for _, item in ipairs(harpoon_files.items) do
    --     table.insert(file_paths, item.value)
    --   end
    --   require("telescope.pickers").new({}, {
    --     prompt_title = "Harpoon",
    --     finder = require("telescope.finders").new_table({
    --       results = file_paths,
    --     }),
    --     previewer = conf.file_previewer({}),
    --     sorter = conf.generic_sorter({}),
    --   }):find()
    -- end

    local map = vim.keymap.set

    map("n", "<A-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: add buffer" })
    map("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Harpoon: buffer 1" })
    map("n", "<C-j>", function() harpoon:list():select(2) end, { desc = "Harpoon: buffer 2" })
    map("n", "<C-k>", function() harpoon:list():select(3) end, { desc = "Harpoon: buffer 3" })
    map("n", "<C-l>", function() harpoon:list():select(4) end, { desc = "Harpoon: buffer 4" })
    -- map("n", "<A-P>", function() harpoon:list():prev() end, { desc = "Harpoon: prev buffer" })
    -- map("n", "<A-N>", function() harpoon:list():next() end, { desc = "Harpoon: next buffer" })
  end,
}
