return {
    "akinsho/git-conflict.nvim",
    version = "*",
    lazy = false, -- must be active to highlight conflicts when a buffer is read
    config = function()
        require("git-conflict").setup({
            default_mappings = false, -- keymaps live in config/git-conflict.lua
        })
    end,
}
