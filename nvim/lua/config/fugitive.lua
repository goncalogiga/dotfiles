vim.keymap.set('n', "<leader>gf", ":vertical Git<CR>")

vim.keymap.set('n', "<leader>gl", ":vertical Git log<CR>")
vim.keymap.set('n', "<leader>got", ":vertical Git log --oneline --decorate --graph<CR>")
vim.keymap.set('n', "<leader>gt", ":vertical Git log --decorate --graph<CR>")
vim.keymap.set('n', "<leader>grl", ":vertical Git reflog --date=local<CR>")
vim.keymap.set('n', "<leader>gcrl", ":vertical Git reflog --format='CommitDate: %cd | AuthorDate: %aD | %gs | %h | %gd'<CR>")
vim.keymap.set('n', "<leader>gb", ":vertical Git blame<CR>")
-- === Replaced by vscode-diff ===
--
-- vim.keymap.set('n', "<leader>gd", ":vertical Gdiffsplit<CR>")
-- vim.keymap.set('n', "<leader>gc", ":vertical Gdiffsplit ")
--
-- ===                         ===
vim.keymap.set('n', "<leader>gm", ":vsplit<CR>:Gedit :%<left><left>")
