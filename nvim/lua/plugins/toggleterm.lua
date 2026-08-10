return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<A-t>", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
    { "<A-p>", "<cmd>2TermExec cmd='htop' direction=float<CR>", desc = "HTop terminal" },
  },
  config = function()
    local status_ok, toggleterm = pcall(require, "toggleterm")
    if not status_ok then return end

    -- -----------------------
    -- ToggleTerm setup
    -- -----------------------
    toggleterm.setup({
      size = 110,
      open_mapping = [[<A-t>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "vertical",
      close_on_exit = true,
      -- shell = vim.o.shell,
      shell = "/bin/bash",
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    })

    -- -----------------------
    -- Terminal keymaps
    -- -----------------------
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<C-esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<A-p>", [[<cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<A-h>", [[<cmd>wincmd h<CR>]], {})
      vim.keymap.set("t", "<A-j>", [[<cmd>wincmd j<CR>]], {})
      vim.keymap.set("t", "<A-k>", [[<cmd>wincmd k<CR>]], {})
      vim.keymap.set("t", "<A-l>", [[<cmd>wincmd l<CR>]], {})
    end

    -- Only for toggleterm buffers
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
  end,
}
