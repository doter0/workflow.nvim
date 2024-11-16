local M = {}

-- Directory
M.workflow_dir = vim.fn.stdpath("config") .. "/workflow/"
M.workflow_ext = ".workflow"
M.inbox_file = M.workflow_dir .. "inbox" .. M.workflow_ext
M.project_dir = M.workflow_dir

-- Header width
M.width_complete = 6
M.width_desc = 25
M.width_tag = 11
M.width_project = 11
M.width_priority = 3
M.width_due = 11
M.width_dur = 4

-- Header_lines
local header = string.format(
    "%-" .. M.width_complete .. "s %-" .. M.width_desc .. "s %-" .. M.width_tag "s %-" .. M.width_project .. "s %-" .. M.width_due .. "s %-".. M.width_dur .. "s",
    "",
    "Description",
    "Tag",
    "Project",
    "Prio",
    "Due Date",
    "Dur"
)

local separator = string.rep("-", #header)

M.header_lines = {
    header,
    separator
}

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

-- 섹션 범위 찾기
function M.serch_section(section_title, section_start, section_end)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i, line in ipairs(lines) do
        if line:match(section_title) then
            section_start = i
        elseif line:match("^# ") and section_start then
            section_end = i - 1
            break
        end
    end
    if not section_start then return end
    section_end = section_end or #lines
    return section_start, section_end
end

return M
