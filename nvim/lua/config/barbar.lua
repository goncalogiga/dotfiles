local map = vim.api.nvim_set_keymap
local opts = { silent = true }

-- Move to previous/next
map('n', '<A-,>', ':BufferPrevious<CR>', opts)
map('n', '<A-;>', ':BufferNext<CR>', opts)
-- Re-order to previous/next
map('n', '<A-Left>', ':BufferMovePrevious<CR>', opts)
map('n', '<A-Right>', ':BufferMoveNext<CR>', opts)
-- Goto buffer in position...
map('n', '<A-&>', ':BufferGoto 1<CR>', opts)
map('n', '<A-é>', ':BufferGoto 2<CR>', opts)
map('n', '<A-">', ':BufferGoto 3<CR>', opts)
map('n', '<A-\'>', ':BufferGoto 4<CR>', opts)
map('n', '<A-(>', ':BufferGoto 5<CR>', opts)
map('n', '<A-->', ':BufferGoto 6<CR>', opts)
map('n', '<A-è>', ':BufferGoto 7<CR>', opts)
map('n', '<A-_>', ':BufferGoto 8<CR>', opts)
map('n', '<A-ç>', ':BufferGoto 9<CR>', opts)
map('n', '<A-à>', ':BufferLast<CR>', opts)
-- Close buffer
map('n', '<A-d>', ':BufferClose<CR>', opts)

-- For terminal management
map('t', '<A-,>', ':BufferPrevious<CR>', opts)
map('t', '<A-;>', ':BufferNext<CR>', opts)