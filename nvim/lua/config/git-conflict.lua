-- Conflict resolution keymaps (akinsho/git-conflict.nvim)
-- The plugin is required lazily on first use; its API is safe to call in any buffer.

local function gc()
    return require("git-conflict")
end

-- Jump between conflicts
vim.keymap.set("n", "]x", function() gc().find_next("ours") end, { desc = "Next conflict" })
vim.keymap.set("n", "[x", function() gc().find_prev("ours") end, { desc = "Prev conflict" })

-- Pick a side for the conflict under the cursor
vim.keymap.set("n", "<leader>co", function() gc().choose("ours") end, { desc = "Conflict: choose ours" })
vim.keymap.set("n", "<leader>ct", function() gc().choose("theirs") end, { desc = "Conflict: choose theirs" })
vim.keymap.set("n", "<leader>cb", function() gc().choose("both") end, { desc = "Conflict: choose both" })
vim.keymap.set("n", "<leader>c0", function() gc().choose("none") end, { desc = "Conflict: choose none" })

-- List all conflicts in the quickfix
vim.keymap.set("n", "<leader>cl", function()
    gc().conflicts_to_qf_items(function(items)
        if #items > 0 then
            vim.fn.setqflist(items, "r")
            vim.cmd("copen")
        else
            vim.notify("No conflicts found", vim.log.levels.INFO)
        end
    end)
end, { desc = "Conflict: list in quickfix" })

-- Pick a conflicting file and open it in a 3-way diff view (LOCAL | BASE | REMOTE)
vim.keymap.set("n", "<leader>gx", function()
    local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
    if not root or root == "" then
        vim.notify("Not in a git repository", vim.log.levels.WARN)
        return
    end

    local conflicts = vim.tbl_filter(function(file)
        return file ~= ""
    end, vim.fn.systemlist({ "git", "-C", root, "diff", "--name-only", "--diff-filter=U" }))

    if #conflicts == 0 then
        vim.notify("No conflicts found", vim.log.levels.INFO)
        return
    end

    require("telescope.builtin").find_files({
        prompt_title = "Conflicts",
        cwd = root,
        find_command = { "git", "diff", "--name-only", "--diff-filter=U" },
        attach_mappings = function(prompt_bufnr)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local file = action_state.get_selected_entry().value
                vim.cmd("edit " .. vim.fn.fnameescape(root .. "/" .. file))
                vim.cmd("Gvdiffsplit")
            end)
            return true
        end,
    })
end, { desc = "Conflict: pick file for 3-way view" })
