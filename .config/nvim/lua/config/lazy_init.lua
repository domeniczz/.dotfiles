local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "config.plugins" },
  },
  defaults = {
    lazy = false,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  checker = {
    enabled = true,
    notify = false,
    frequency = 21600,
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      disabled_plugins = {
        -- "editorconfig",
        -- "matchit",
        -- "matchparen",
        -- "shada",
        "netrwPlugin",
        "spellfile",
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "man",
        "rplugin",
        "tohtml",
        "osc52",
        "tutor",
      },
    },
  },
  -- Only enable profiling when debugging lazy.nvim
  profiling = {
    -- Enables extra stats on the debug tab related to the loader cache
    -- Additionally gathers stats about all package.loaders
    loader = false,
    -- Track each new require in the Lazy profiling tab
    require = false,
  },
})
