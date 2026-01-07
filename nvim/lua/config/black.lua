local function setup_black_autocmd()
    vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.py",
    callback = function()
      local filepath = vim.fn.expand("%")
      local bufnr = vim.api.nvim_get_current_buf()

      local timer = vim.loop.new_timer()
      local timed_out = false
      local job_id

      timer:start(1000, 0, function()
        timed_out = true
        if job_id then
          vim.fn.jobstop(job_id)
        end
        vim.schedule(function()
          vim.b[bufnr].black_deferred = true
          require("notify")(
            "Black took too long — deferring to buffer close.",
            "error"
          )
        end)
      end)

      job_id = vim.fn.jobstart({ "black", filepath }, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_exit = function(_, code, _)
          timer:stop()
          timer:close()

          if timed_out then
            return
          end

          if code == 0 then
            vim.schedule(function()
              vim.cmd("edit!")
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

  vim.api.nvim_create_autocmd("BufWinLeave", {
    pattern = "*.py",
    callback = function()
      if vim.b.black_deferred then
        vim.fn.jobstart({ "black", vim.fn.expand("%") })
        vim.b.black_deferred = false
      end
    end,
  })
end

setup_black_autocmd()