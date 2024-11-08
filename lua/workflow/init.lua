local workflow_dir = vim.fn.stdpath("~") .. "/nvim/workflow/"
local workflow_ext = ".workflow"

local M = {}

local function create_file(filename, content)
    local filepath = workflow_dir .. filename .. workflow_ext

    vim.fn.mkdir(base_dir, "p")

    local fd = vim.loop.fs_open(filepath, "w", 438)
    if not fd then
        print("Unable to create file:" .. filepath)
        return
    end

    vim.loop.fs_write(fd, content or "", -1)

    vim.loop.fs_close(fd)

    print("File has been created:" .. filepath)
end

create_file()

return M

