return {
  "startup-nvim/startup.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },

  -- Set globals BEFORE the plugin loads
  init = function()
    vim.g.startup_bookmarks = {
      ["V"] = "~/.config/nvim/",
    }
  end,

  event = "VimEnter",

  config = function()
    require("startup").setup({
      theme = "dashboard",
    })
  end,
}