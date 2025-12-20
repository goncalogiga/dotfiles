local dap = require("dap")
local dapui = require("dapui")

require("dap-python").setup("python")

-- -------------------------------------
-- Lite DAP UI setup (essentials only)
-- -------------------------------------
dapui.setup({
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.7 },
        { id = "repl", size = 0.3 },
      },
      size = 15,        -- total height of bottom panel
      position = "bottom",
    },
  },
  floating = {
    border = "rounded",
    mappings = { close = { "q", "<Esc>" } },
  },
  controls = { enabled = false },
})

-- -------------------------------------
-- Notify events
-- -------------------------------------
dap.listeners.after.event_initialized["notify"] = function()
  require("notify")("✅ Debugger attached successfully!", "info", { title = "nvim-dap" })
end

dap.listeners.before.event_terminated["notify"] = function()
  require("notify")("🛑 Debugger terminated.", "warn", { title = "nvim-dap" })
end

dap.listeners.before.event_exited["notify"] = function()
  require("notify")("🚪 Debugger session ended.", "info", { title = "nvim-dap" })
end

-- Auto-open / close UI on session start/end
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- -----------------------------
-- Python attach configuration 
-- -----------------------------
dap.configurations.python = {
  {
    type = "python",
    request = "attach",
    name = "Attach to debugpy in Docker",
    connect = {
      host = "127.0.0.1",
      port = 5678,
    },
    pathMappings = {
      {
        localRoot = vim.fn.getcwd() .. "/src",
        remoteRoot = "/corneille/src",
      },
    },
  },
}

-- ---------
-- Keymaps 
-- ---------
local opts = { noremap = true, silent = true, desc = "" }
vim.keymap.set("n", "<F5>", function() dap.continue() end, vim.tbl_extend("force", opts, { desc = "DAP Continue" }))
vim.keymap.set("n", "<F10>", function() dap.step_over() end, vim.tbl_extend("force", opts, { desc = "DAP Step Over" }))
vim.keymap.set("n", "<F11>", function() dap.step_into() end, vim.tbl_extend("force", opts, { desc = "DAP Step Into" }))
vim.keymap.set("n", "<F12>", function() dap.step_out() end, vim.tbl_extend("force", opts, { desc = "DAP Step Out" }))

vim.keymap.set("n", "<S-F5>", function() dap.terminate() end, vim.tbl_extend("force", opts, { desc = "DAP Terminate" }))

vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end, vim.tbl_extend("force", opts, { desc = "Toggle Breakpoint" }))

vim.keymap.set("n", "<leader>du", function() dapui.toggle() end, vim.tbl_extend("force", opts, { desc = "Toggle DAP UI" }))


-- vim.keymap.set("n", "<leader>B", function()
--   dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
-- end, vim.tbl_extend("force", opts, { desc = "Conditional Breakpoint" }))

-- vim.keymap.set("n", "<leader>lp", function()
--   dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
-- end, vim.tbl_extend("force", opts, { desc = "Log Point" }))

-- vim.keymap.set("n", "<leader>dr", function() dap.repl.toggle() end, vim.tbl_extend("force", opts, { desc = "Toggle REPL" }))
