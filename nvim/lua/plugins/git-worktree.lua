return {
    "ThePrimeagen/git-worktree.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local git_worktree = require("git-worktree")
        git_worktree.setup({})
        git_worktree.on_tree_change(function(op)
            if op == git_worktree.Operations.Switch then
                require("nvim-tree.api").tree.change_root(vim.fn.getcwd())
            end
        end)
    end,
}
