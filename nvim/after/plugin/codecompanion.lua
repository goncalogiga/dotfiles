-- Inspired by https://programmador.com/posts/2025/setting-up-a-local-llm/
require("codecompanion").setup({
    adapters = {
        vllm = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                    url = "http://lancelot:8099",
                    chat_url = "/v1/chat/completions",
                    model = "openai/gpt-oss-120b",
                    models_endpoint = "/v1/models",
                },
            })
        end,
    },
    strategies = {
        chat = {
            adapter = "vllm",
        },
        inline = {
            adapter = "vllm",
        },
        cmd = {
            adapter = "vllm",
        },
    },
})

vim.api.nvim_set_keymap('n', '<A-i>', ':CodeCompanionChat<CR>', {noremap = true})
vim.api.nvim_set_keymap('v', '<leader>ai', ":'<,'>CodeCompanion<CR>", {noremap = true})
