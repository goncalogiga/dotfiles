require'nvim-treesitter'.install { 'rust', 'toml', 'python', 'c' }

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'python', 'rust', 'toml' },
    callback = function() vim.treesitter.start() end,
})
