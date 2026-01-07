vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fl', ':Telescope current_buffer_fuzzy_find<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope buffers<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fr', ':Telescope oldfiles<CR>', {noremap = true})

-- Find words with https://github.com/nvim-telescope/telescope-live-grep-args.nvim
vim.api.nvim_set_keymap('n', '<leader>fw', ':lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>', {noremap = true})
-- Find PYTHON files only
vim.api.nvim_set_keymap('n', '<leader>fp', ':lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>-tpy ', {noremap = true})
-- Find python CODE files only (and no tests)
vim.api.nvim_set_keymap('n', '<leader>fc', ':lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>-tpy -g "!tests/*" ', {noremap = true})

-- Telescope extensions setup
local telescope = require("telescope")

telescope.load_extension("live_grep_args")
