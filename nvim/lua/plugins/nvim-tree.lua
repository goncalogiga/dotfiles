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
        preserve_window_proportions = true,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })

    -- keep the tree at its configured width: without winfixwidth, resizes from
    -- other windows (toggleterm's `vertical resize 110`) squeeze the tree to
    -- winminwidth
    require("nvim-tree.api").events.subscribe("TreeOpen", function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
          vim.api.nvim_set_option_value("winfixwidth", true, { win = win })
        end
      end
    end)
    end,

    lazy=false
}
