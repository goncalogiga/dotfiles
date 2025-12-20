vim.g.mapleader = " "

-- show line numbers
vim.opt.nu = true

-- tabs configuration and indenting settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- switch file history to undotree
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- disable highlight persistance after search
vim.opt.hlsearch = false

-- dynamic highlighting during search
vim.opt.incsearch = true

-- coloring
vim.opt.termguicolors = true

-- fast update time
vim.opt.updatetime = 250

-- Enable trimmming of trailing whitespace
vim.g.neoformat_basic_format_trim = 1

-- No wrapping of lines
vim.wo.wrap = false

-- Buffer zone at the end of file
vim.opt.scrolloff=999999

-- Use virtual edit with visual block mode
vim.opt.virtualedit = "block"

-- Locate changes when using %s/...
vim.opt.inccommand = "split"

-- Use titles for Kitty Terminal
vim.o.title = true

-- Function to get Git root or fallback to file directory
local function get_git_or_dir()
    local filepath = vim.fn.expand('%:p')
    local git_root = vim.fn.systemlist('git -C "' .. vim.fn.fnamemodify(filepath, ':h') .. '" rev-parse --show-toplevel')[1]

    if vim.v.shell_error == 0 and git_root and git_root ~= '' then
        return vim.fn.fnamemodify(git_root, ':t')  -- Git repo name
    else
        return vim.fn.fnamemodify(filepath, ':h:t') -- Current file's directory name
    end
end

-- Set titlestring using an expression
vim.o.titlestring = "%{v:lua.get_git_or_dir()}"
_G.get_git_or_dir = get_git_or_dir  -- Make it accessible from the expression
