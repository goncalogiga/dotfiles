return {
    -- FZF
    {
        "junegunn/fzf",
        build = "./install --bin",
    },
    {
        "junegunn/fzf.vim",
        dependencies = { "junegunn/fzf" },
        cmd = { "Files", "Rg", "Buffers" },
    },

    -- UI
    { "lewis6991/gitsigns.nvim", event = "BufReadPost", config = true },
    { "nvim-tree/nvim-web-devicons", lazy = true },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
    },

    -- Markdown preview
    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        build = function()
            if vim.fn.executable("npm") == 1 then
            vim.fn["mkdp#util#install"]()
            end
        end,
    },

    -- Notify
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        config = function()
            vim.notify = require("notify")
        end,
    },
}