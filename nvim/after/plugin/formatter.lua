-- Utilities for creating configurations
local util = require "formatter.util"

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup {
  -- Enable or disable logging
  logging = true,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = {
    -- Formatter configurations for filetype "lua" go here
    -- and will be executed in order
    lua = {
      -- "formatter.filetypes.lua" defines default configurations for the
      -- "lua" filetype
      require("formatter.filetypes.lua").stylua,

      -- You can also define your own configuration
      function()
        -- Supports conditional formatting
        if util.get_current_buffer_file_name() == "special.lua" then
          return nil
        end

        -- Full specification of configurations is down below and in Vim help
        -- files
        return {
          exe = "stylua",
          args = {
            "--search-parent-directories",
            "--stdin-filepath",
            util.escape_path(util.get_current_buffer_file_path()),
            "--",
            "-",
          },
          stdin = true,
        }
      end
    },

    -- Use the special "*" filetype for defining formatter configurations on
    -- any filetype
    ["*"] = {
      -- "formatter.filetypes.any" defines default configurations for any
      -- filetype
      require("formatter.filetypes.any").remove_trailing_whitespace
    }
  }
}

-- Format python files with black
-- vim.api.nvim_create_autocmd("BufWritePost", {
--     pattern = "*.py",
--     callback = function()
--         vim.fn.jobstart({ "black", vim.fn.expand("%") }, {
--         stdout_buffered = true,
--         stderr_buffered = true,
--         -- Reload the current buffer after black's modifications
--         on_exit = function(_, code, _)
--             if code == 0 then
--                 vim.schedule(function()
--                 vim.cmd("edit!")
--             end)
--             -- Optional error messages when black fails
--             else
--                 -- print("Black failed to format !") -- Simple error code
--                 require("notify")("Black failed to format file.", "error")
--             end
--         end,
--     })
--     end,
-- })
--
--
local function setup_black_autocmd()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.py",
    callback = function()
      local filepath = vim.fn.expand("%")
      local bufnr = vim.api.nvim_get_current_buf()

      -- start the timer
      local timer = vim.loop.new_timer()
      local timed_out = false

      local job_id

      -- schedule fallback if >1s
      timer:start(1000, 0, function()
        timed_out = true
        if job_id then
          vim.fn.jobstop(job_id)
        end
        vim.schedule(function()
          vim.b[bufnr].black_deferred = true
          require("notify")("Black took too long — deferring to buffer close.", "error")
        end)
      end)

      -- launch black job
      job_id = vim.fn.jobstart({ "black", filepath }, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_exit = function(_, code, _)
          timer:stop()
          timer:close()
          if timed_out then
            return -- already handled by fallback
          end

          if code == 0 then
            vim.schedule(function()
              vim.cmd("edit!") -- reload buffer after black modifies file
            end)
          else
            vim.schedule(function()
              require("notify")("Black failed to format file.", "error")
            end)
          end
        end,
      })
    end,
  })

  -- fallback autocmd: when buffer closes, if we marked it deferred
  vim.api.nvim_create_autocmd("BufWinLeave", {
    pattern = "*.py",
    callback = function()
      if vim.b.black_deferred then
        local filepath = vim.fn.expand("%")
        vim.fn.jobstart({ "black", filepath })
        vim.b.black_deferred = false
      end
    end,
  })
end

setup_black_autocmd()
