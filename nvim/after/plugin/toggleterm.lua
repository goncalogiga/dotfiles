local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

-- Toggle term general setup
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
    shell = vim.o.shell,
    float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
            border = "Normal",
            background = "Normal",
        },
    },
})

function _G.set_terminal_keymaps()
    local opts = {buffer = 0}
    vim.keymap.set('t', '<C-esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<A-p>', [[<Cmd>wincmd h<CR>]], opts) -- Used to disable htop
    vim.keymap.set('t', '<A-h>', [[<Cmd>wincmd h<CR>]], {})
    vim.keymap.set('t', '<A-j>', [[<Cmd>wincmd j<CR>]], {})
    vim.keymap.set('t', '<A-k>', [[<Cmd>wincmd k<CR>]], {})
    vim.keymap.set('t', '<A-l>', [[<Cmd>wincmd l<CR>]], {})
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- htop window
local htop_cmd = "htop"
vim.keymap.set('n', "<A-p>", ":2TermExec cmd='"..htop_cmd.."' direction=float<CR>")

-- To integrate nicely with :terminal
vim.keymap.set('t', "<A-t>", "<Cmd>ToggleTerm<CR>")
