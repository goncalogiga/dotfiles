return {
    "wookayin/semshi",
    build = ":UpdateRemotePlugins",
    version = "*",  -- Recommended to use the latest release
    init = function()  -- example, skip if you're OK with the default config
     vim.g['semshi#error_sign'] = false
    end,
    config = function()
     -- any config or setup that would need to be done after plugin loading
    end,
}

-- IMPORTANT : 
-- Make sure you run :UpdateRemotePlugins
