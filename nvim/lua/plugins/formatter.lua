return {
    "mhartington/formatter.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("config.formatter")
        require("config.black")
    end,
}