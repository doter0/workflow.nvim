local utils = require('workflow.utils')

local M = {}

-- Define the function to add a thing to the inbox.workflow file
function M.add_thing(contents)
  -- Try to find if inbox.workflow buffer is already open
    local buf = nil
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b) == utils.inbox_file then
            buf = b
            break
        end
    end

    -- Define the function to insert the new task below "# Things" or at the end
    local function insert_task(lines)
        for i, line in ipairs(lines) do
            if line:match("# Things") then
                table.insert(lines, i + 1, "- " .. contents)
                break
            end
        end
        return lines
    end

    -- If buffer is open, modify it directly
    if buf then
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        lines = insert_task(lines)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        print("Added to open inbox: " .. contents)
    else
      -- If buffer is not open, read the file, modify
        local lines = vim.fn.readfile(utils.inbox_file)
        lines = insert_task(lines)
        vim.fn.writefile(lines, utils.inbox_file)
        print("Added to inbox: " .. contents)
    end
end

return M
