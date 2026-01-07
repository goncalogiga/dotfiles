-- Compare file with any branch
vim.keymap.set("n", "<leader>gc", function()
  require("telescope.builtin").git_branches({
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local branch = action_state.get_selected_entry().value
        vim.cmd("CodeDiff file " .. branch)
      end)

      return true
    end,
  })
end, { desc = "CodeDiff vs Git branch" })

-- Diff with any branch
vim.keymap.set("n", "<leader>gd", function()
  require("telescope.builtin").git_branches({
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local branch = action_state.get_selected_entry().value
        vim.cmd("CodeDiff " .. branch)
      end)

      return true
    end,
  })
end, { desc = "CodeDiff vs Git branch" })
