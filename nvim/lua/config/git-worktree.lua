-- Worktree management (ThePrimeagen/git-worktree.nvim, telescope extension)

local function git_worktree_ext()
    local telescope = require("telescope")
    if not telescope.extensions.git_worktree then
        telescope.load_extension("git_worktree")
    end
    return telescope.extensions.git_worktree
end

vim.keymap.set("n", "<leader>ww", function()
    git_worktree_ext().git_worktrees()
end, { desc = "Worktree: switch" })

vim.keymap.set("n", "<leader>wc", function()
    git_worktree_ext().create_git_worktree()
end, { desc = "Worktree: create" })
