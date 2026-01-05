return {

    -- Colorscheme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin-macchiato")
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-live-grep-args.nvim",
        },
        cmd = "Telescope",
    },

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

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
    },

    -- Git
    { "tpope/vim-fugitive", cmd = { "Git", "Gdiffsplit" } },
    { "shumphrey/fugitive-gitlab.vim" },

    -- LSP Zero
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v2.x",
        dependencies = {
            "neovim/nvim-lspconfig",
            {
                "williamboman/mason.nvim",
                build = function()
                    pcall(vim.cmd, "MasonUpdate")
                end,
            },
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
        },
    },

    -- Formatter
    { "mhartington/formatter.nvim", cmd = "Format" },

    -- Toggleterm
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = true,
        cmd = { "ToggleTerm" },
    },

    -- Nvim-tree
    { "nvim-tree/nvim-tree.lua", cmd = "NvimTreeToggle" },

    -- UI
    { "romgrk/barbar.nvim", event = "BufReadPost" },
    { "lewis6991/gitsigns.nvim", event = "BufReadPost", config = true },
    { "nvim-tree/nvim-web-devicons", lazy = true },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
    },

    -- Startup screen
    {
        "startup-nvim/startup.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        event = "VimEnter",
        config = true,
    },

    -- Markdown preview (SAFE)
    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        build = function()
            if vim.fn.executable("npm") == 1 then
            vim.fn["mkdp#util#install"]()
            end
        end,
    },

    -- Neorg (pinned)
    {
        "nvim-neorg/neorg",
        tag = "v6.2.0",
        dependencies = { "nvim-lua/plenary.nvim" },
        ft = "norg",
    },

    -- Notify
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        config = function()
            vim.notify = require("notify")
        end,
    },

  -- CodeCompanion (SAFE)
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        event = "VeryLazy",
        config = function()
            local ok, cc = pcall(require, "codecompanion")
            if ok then
                cc.setup()
            end
        end,
    },
}