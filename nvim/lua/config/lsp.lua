local cmp = require('cmp')
local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load()

-- Python system setup --
vim.g.python3_host_prog = vim.fn.expand("$DOTFILES_PATH/.venv/bin/python")


-- Completion setup --
cmp.setup({
    snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer', keyword_length = 3 },
        { name = 'path' },
        { name = 'luasnip', keyword_length = 2 },
    },
})

-- Key maps --
local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>ek", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>ej", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end

-- Defining syntax error format --
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
})

-- Setting up pyright --
vim.lsp.config('pyright', {
    cmd = { 
        vim.fn.expand("$DOTFILES_PATH/.venv/bin/pyright-langserver"), 
        '--stdio' 
    },
    filetypes = { 'python' },
    on_attach = on_attach,
    settings = {
        python = {
            venvPath = ".",
            venv = ".venv",
            analysis = {
                typeCheckingMode = "off",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'openFilesOnly',
            },
        },
    },
})
vim.lsp.enable("pyright")
