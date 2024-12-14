return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  lazy = false,
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

    -- Open harpoon list menu
    -- vim.keymap.set("n", "<A-e>", function() toggle_telescope(harpoon:list()) end, { desc = "Open harpoon menu" })
    vim.keymap.set("n", "<A-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    -- Add buffer to harpoon list
    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Add buffer to harpoon" })
    -- Toggle specific buffer in list
    vim.keymap.set("n", "<A-1>", function() harpoon:list():select(1) end, { desc = "Switch to buffer 1"})
    vim.keymap.set("n", "<A-2>", function() harpoon:list():select(2) end, { desc = "Switch to buffer 2"})
    vim.keymap.set("n", "<A-3>", function() harpoon:list():select(3) end, { desc = "Switch to buffer 3"})
    vim.keymap.set("n", "<A-4>", function() harpoon:list():select(4) end, { desc = "Switch to buffer 4"})
    -- Toggle previous & next buffers stored within harpoon list
    vim.keymap.set("n", "<A-P>", function() harpoon:list():prev() end, { desc = "Switch to prev buffer"})
    vim.keymap.set("n", "<A-N>", function() harpoon:list():next() end, { desc = "Switch to next buffer"})
  end,
}
