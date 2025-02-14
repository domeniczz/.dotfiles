return {
  "ThePrimeagen/harpoon",
  enabled = true,
  branch = "harpoon2",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon.setup()

    -- -- Configuration harpoon to use telescope ui
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

    -- Open harpoon list menu
    map("n", "<A-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    -- Add buffer to harpoon list
    map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Add buffer to harpoon" })
    -- Toggle specific buffer in list
    map("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Switch to buffer 1" })
    map("n", "<C-j>", function() harpoon:list():select(2) end, { desc = "Switch to buffer 2" })
    map("n", "<C-k>", function() harpoon:list():select(3) end, { desc = "Switch to buffer 3" })
    map("n", "<C-l>", function() harpoon:list():select(4) end, { desc = "Switch to buffer 4" })
    map("n", "<leader><C-h>", function() harpoon:list():replace_at(1) end)
    map("n", "<leader><C-t>", function() harpoon:list():replace_at(2) end)
    map("n", "<leader><C-n>", function() harpoon:list():replace_at(3) end)
    map("n", "<leader><C-s>", function() harpoon:list():replace_at(4) end)
    -- Toggle previous & next buffers stored within harpoon list
    -- map("n", "<A-P>", function()
    --   harpoon:list():prev()
    -- end, { desc = "Switch to prev buffer" })
    -- map("n", "<A-N>", function()
    --   harpoon:list():next()
    -- end, { desc = "Switch to next buffer" })
  end,
}
