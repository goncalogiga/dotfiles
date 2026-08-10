local bin = vim.fn.expand("$DOTFILES_PATH/.venv/bin/")

vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("PyFormat", { clear = true }),
    pattern = "*.py",

    callback = function(args)
        local buf = args.buf
        
        if vim.b[buf].formatting then return end

        local path = vim.api.nvim_buf_get_name(buf)
        local tick = vim.api.nvim_buf_get_changedtick(buf)
        local src = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"

        vim.b[buf].formatting = true

        vim.system({
          "sh", "-c",
          ("%sisort -q --profile black --filename %q - | %sblack -q --fast --stdin-filename %q -")
            :format(bin, path, bin, path),
        }, { stdin = src, text = true }, function(res)

        vim.schedule(function()
            vim.b[buf].formatting = false

            if res.code ~= 0 or res.stdout == "" then
              return vim.notify("py-format failed: " .. (res.stderr or ""), vim.log.levels.WARN)
            end

            -- bail if the user kept typing while we were formatting
            if not vim.api.nvim_buf_is_valid(buf) then return end
            if vim.api.nvim_buf_get_changedtick(buf) ~= tick then return end

            local new = vim.split(res.stdout:gsub("\n$", ""), "\n")
            if vim.deep_equal(new, vim.api.nvim_buf_get_lines(buf, 0, -1, false)) then return end

            local view = vim.fn.winsaveview()
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, new)
            vim.fn.winrestview(view)
            vim.api.nvim_buf_call(buf, function() vim.cmd("noautocmd silent write") end)
            end)
        end)
    end,
})
