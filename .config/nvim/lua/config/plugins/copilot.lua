local function add_to_blink_cmp_source()
  local ok, blink_sources = pcall(require, "blink.cmp.sources.lib")
  if not ok then return end
  local config = require("blink.cmp.config")
  if not vim.tbl_contains(config.sources.default, "copilot") then
    table.insert(config.sources.default, "copilot")
    blink_sources.providers = {}
  end
end

local function remove_from_blink_cmp_source()
  local ok, blink_sources = pcall(require, "blink.cmp.sources.lib")
  if not ok then return end
  local config = require("blink.cmp.config")
  config.sources.default = vim.tbl_filter(function(s) return s ~= "copilot" end, config.sources.default)
  blink_sources.providers = {}
end

return {
  "zbirenbaum/copilot.lua",
  branch = "master",
  enabled = true,
  lazy = true,
  dependencies = {
    "giuxtaposition/blink-cmp-copilot",
  },
  cmd = {
    -- "Copilot",
    "CopilotToggle",
  },
  config = function()
    require("copilot").setup({})
    -- add_to_blink_cmp_source()

    vim.api.nvim_create_user_command("CopilotToggle", function()
      local client = require("copilot.client").get()
      if client then
        require("copilot.command").disable()
        remove_from_blink_cmp_source()
        vim.notify("Copilot disabled")
      else
        require("copilot.command").enable()
        add_to_blink_cmp_source()
        vim.notify("Copilot enabled")
      end
    end, {})
  end,
}
