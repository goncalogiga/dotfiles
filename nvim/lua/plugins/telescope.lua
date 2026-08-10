return {
    "nvim-telescope/telescope.nvim",
    -- tag = "0.1.8", -- pinned: master broken on nvim 0.13-dev, utils.if_nil resolves to nil (vim.F.if_nil removed)
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-live-grep-args.nvim",
    },
    cmd = "Telescope"
}
