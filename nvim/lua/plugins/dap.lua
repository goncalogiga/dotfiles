return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "nvim-neotest/nvim-nio", -- required by dap-ui
      "rcarriga/nvim-notify",
    },
    config = function()
      require("config.dap")
    end,
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP Step Out" },
      { "<S-F5>", function() require("dap").terminate() end, desc = "DAP Terminate" },
      { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
  },
}