-- vim.api.nvim_set_keymap('n', '<A-i>', ':AvanteAsk<CR>', {noremap = true})

-- -- require('avante_lib').load()
-- require("avante").setup({
--     provider = "openai",
--     auto_suggestions_provider = "openai",
--     providers = {
--         openai = {
--             endpoint = "http://lancelot:8099/v1/chat/",
--             model = "openai/gpt-oss-120b",
--             api_key = "",
--             extra_request_body = {
--                 temperature = 0,
--                 max_tokens = 10000,
--             }

--         }
--     }
-- })
