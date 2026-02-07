-- it is important to remap the leader key as soon as possible
vim.g.mapleader = " " 

vim.g.maplocalleader = "," 

require("goncalo.set")
require("goncalo.remap")
require("goncalo.lazy")   -- sets up lazy.nvim
require("plugins")        -- plugin specs
require("config")         -- plugin configuration
