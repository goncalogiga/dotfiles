local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  "pyright",
  "rust_analyzer",
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

-- -----------------------
-- nvim-cmp configuration
-- -----------------------
local cmp = require("cmp")
local cmp_insert = { behavior = cmp.SelectBehavior.Insert }

local cmp_mappings = lsp.defaults.cmp_mappings({
  ["<S-Tab>"] = cmp.mapping.select_prev_item(cmp_insert),
  ["<Tab>"] = cmp.mapping.select_next_item(cmp_insert),
})

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  mapping = cmp_mappings,
  sources = {
    { name = "path" },
    { name = "nvim_lsp" },
    { name = "buffer", keyword_length = 3 },
    { name = "luasnip", keyword_length = 2 },
  },
})

lsp.setup_nvim_cmp()

-- -----------------------
-- Preferences
-- -----------------------
lsp.set_preferences({
  suggest_lsp_servers = false,
  sign_icons = {
    error = "E",
    warn = "W",
    hint = "H",
    info = "I",
  },
})

-- -----------------------
-- LSP keymaps
-- -----------------------
lsp.on_attach(function(_, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set(
    "n",
    "<leader>e",
    function()
      vim.diagnostic.open_float(0, { scope = "line" })
    end,
    opts
  )
end)

lsp.setup()

-- -----------------------
-- Diagnostics
-- -----------------------
vim.diagnostic.config({
  virtual_text = true,
})

-- -----------------------
-- Ruff (Python linting)
-- -----------------------
require("lspconfig").ruff.setup({})