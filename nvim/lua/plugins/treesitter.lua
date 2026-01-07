return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Parsers to ensure installed
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "luadoc", "markdown" },

      -- Install parsers asynchronously
      sync_install = false,

      -- Automatically install missing parsers on buffer enter
      auto_install = true,

      -- Parsers to ignore
      ignore_install = { "javascript" },

      highlight = {
        enable = true,
        -- Use vim regex highlighting for additional languages if needed
        additional_vim_regex_highlighting = false,
      },
    })
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects", -- optional but recommended
  },
}