require'nvim-treesitter'.install { 'rust', 'python', 'c' }

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'python' },
    callback = function() vim.treesitter.start() end,
})
