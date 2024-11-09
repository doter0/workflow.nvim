local M = {}

M.workflow_dir = vim.fn.stdpath("config") .. "/workflow/"
M.workflow_ext = ".workflow"
M.inbox_file = M.workflow_dir .. "inbox" .. M.workflow_ext

function M.create_file(filename, content)
    local filepath = M.workflow_dir .. filename .. M.workflow_ext

    -- 파일이 이미 존재하는지 확인
    if vim.loop.fs_stat(filepath) then
        print("File already exists:" .. filepath)
        return  -- 파일이 존재하면 함수 종료
    end

    vim.fn.mkdir(M.workflow_dir, "p")

    local fd = vim.loop.fs_open(filepath, "w", 438)
    if not fd then
        print("Unable to create file:" .. filepath)
        return
    end

    -- content가 리스트인 경우 각 줄을 개별적으로 작성
    if type(content) == "table" then
        for _, line in ipairs(content) do
            vim.loop.fs_write(fd, line .. "\n", -1)
        end
    else
        -- content가 문자열이면 그대로 작성
        vim.loop.fs_write(fd, content or "", -1)
    end

    vim.loop.fs_close(fd)

    print("File has been created:" .. filename)
end

return M
