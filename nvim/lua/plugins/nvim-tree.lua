return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
    "nvim-tree/nvim-web-devicons",
    },

    -- IMPORTANT: disable netrw BEFORE loading the plugin
    init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    end,

    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus" },

    config = function()
    require("nvim-tree").setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })
    end,

    lazy=false
}