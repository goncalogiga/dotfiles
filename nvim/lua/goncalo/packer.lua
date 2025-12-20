vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer
    use 'wbthomason/packer.nvim'

    -- Colorscheme
    use {
        "catppuccin/nvim",
        as = "catppuccin",
        config = function()
            vim.cmd.colorscheme("catppuccin-macchiato")
        end
    }

    -- Telescope
    use {
        "nvim-telescope/telescope.nvim",
        requires = {
            { "nvim-telescope/telescope-live-grep-args.nvim" },
        }
    }

    -- FZF (fuzzy search engine)
    use('junegunn/fzf', {run = './install --bin'})
    use('junegunn/fzf.vim')

    -- Treesitter (syntax highlight)
    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

    -- Git Fugitive
    use('tpope/vim-fugitive')
    use('shumphrey/fugitive-gitlab.vim')

    -- LSP
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {
                'williamboman/mason.nvim',
                run = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end,
            },
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'L3MON4D3/LuaSnip'},
        }

    }

    -- Formatter
    use { 'mhartington/formatter.nvim' }

    -- Floating terminal
    use {"akinsho/toggleterm.nvim", tag = '*', config = function()
        require("toggleterm").setup()
    end}

    -- Nvim tree
    use('nvim-tree/nvim-tree.lua')

    -- Tabulations
    use 'romgrk/barbar.nvim'
    use('lewis6991/gitsigns.nvim') -- OPTIONAL: for git status

    -- Quickly comment
    use('tpope/vim-commentary')

    -- A plugin to manage formatting
    use('sbdchd/neoformat')

    -- A plugin to have icons (buggy)
    use('nvim-tree/nvim-web-devicons')

    -- A nice status line
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    -- A nice init screen
    use {
        "startup-nvim/startup.nvim",
        requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"},
        config = function()
            require("startup").setup()
        end
    }

    -- Open CSVs in neovim
    use("mechatroner/rainbow_csv")

    -- More LSP/Autocompletion plugins
    use("hrsh7th/cmp-path")
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-buffer")
    use("saadparwaiz1/cmp_luasnip")
    use("rafamadriz/friendly-snippets")

    -- A better git log
    use("kablamo/vim-git-log")

    -- Render markdowns (warning: this needs npm)
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })
    use {
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
        ft = { "markdown" }
    }

    -- Tag bar
    use("preservim/tagbar")

    -- Goyo
    use("junegunn/goyo.vim")

    -- Neorg
    use {
        "nvim-neorg/neorg",
        -- This is pinned for now. v7.0.O throws an error on startup
        tag = "v6.2.0",
        -- !!! RUN THIS AFTER INSTALLATION !!!
        -- run = ":Neorg sync-parsers",
        requires = "nvim-lua/plenary.nvim"
    }

    -- notify
    use("rcarriga/nvim-notify")

    -- Multicursor
    -- Doc: https://github.com/mg979/vim-visual-multi/wiki/Mappings
    use {
        'mg979/vim-visual-multi',
        branch = 'master',
    }

    -- Avante (LLMs inside of neovim)
        -- Required plugins
    use 'nvim-lua/plenary.nvim'
    use 'MunifTanjim/nui.nvim'
    use 'MeanderingProgrammer/render-markdown.nvim'

        -- Optional dependencies
    use 'hrsh7th/nvim-cmp'
    use 'nvim-tree/nvim-web-devicons' -- or use 'echasnovski/mini.icons'
    use 'HakonHarnes/img-clip.nvim'
    use 'zbirenbaum/copilot.lua'
    use 'stevearc/dressing.nvim' -- for enhanced input UI
    use 'folke/snacks.nvim' -- for modern input UI

        -- Avante.nvim with build process
    -- use {
    --     'yetone/avante.nvim',
    --     branch = 'main',
    --     run = 'make',
    -- }

    -- codecompaninon (should be better than Avante.nvim)
    use({
        "olimorris/codecompanion.nvim",
        config = function()
            require("codecompanion").setup()
        end,
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        }
    })

    -- Neotest
    use {
        "nvim-neotest/neotest-python",
        requires = {
            "nvim-neotest/neotest",
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter"
        },
    }

    -- Trying out lazygit
    use({
        "kdheepak/lazygit.nvim",
        -- optional for floating window border decoration
        requires = {
            "nvim-lua/plenary.nvim",
        },
    })

    use ({
        "mfussenegger/nvim-dap",
        requires = {
            "rcarriga/nvim-dap-ui",   -- Optional: nice UI
            "mfussenegger/nvim-dap-python",  -- Python support
        }
    })

    -- VSCode diff
    use ({
        "esmuellert/vscode-diff.nvim",
        requires = { "MunifTanjim/nui.nvim" },
        cmd = "CodeDiff",
    })

end)


