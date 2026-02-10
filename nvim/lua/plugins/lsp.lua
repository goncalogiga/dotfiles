-- init.lua or lua/plugins/lsp.lua
return {
  -- nvim-cmp (completion engine)
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",   -- lazy-load when entering insert mode
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",   -- LSP completion source
      "hrsh7th/cmp-buffer",     -- buffer words completion
      "hrsh7th/cmp-path",       -- file path completion
      "saadparwaiz1/cmp_luasnip", -- snippet completions
      "L3MON4D3/LuaSnip",       -- snippet engine
      "rafamadriz/friendly-snippets", -- ready-made snippets
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer", keyword_length = 3 },
          { name = "path" },
          { name = "luasnip", keyword_length = 2 },
        },
      })
    end,
  },

  -- Optional: nice snippet collection
  {
    "rafamadriz/friendly-snippets",
    event = "InsertEnter",
  },
}
