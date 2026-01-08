-- =====================================
-- LSP-ZERO v4+
-- =====================================

local lsp = require("lsp-zero")

-- =====================================
-- Mason
-- =====================================

require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "rust_analyzer",
    "lua_ls",
    "ruff",
  },
})

-- =====================================
-- LSP servers
-- =====================================

local lspconfig = require("lspconfig")

-- Lua
lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
      },
    },
  },
})

-- Python
lspconfig.pyright.setup({})
lspconfig.ruff.setup({})

-- Rust
lspconfig.rust_analyzer.setup({})

-- =====================================
-- nvim-cmp
-- =====================================

local cmp = require("cmp")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  mapping = {
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "buffer", keyword_length = 3 },
    { name = "luasnip", keyword_length = 2 },
  },
})

-- =====================================
-- Keymaps
-- =====================================

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  end,
})

-- =====================================
-- Diagnostics
-- =====================================

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  severity_sort = true,
})