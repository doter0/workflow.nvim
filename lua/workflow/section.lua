local utils = require("workflow.utils")
local M = {}

-- 엔터 키 동작 처리
function M.handle_enter()
    local line = vim.api.nvim_get_current_line
    local section = M.get_section()

    if section == "Actions" then
        M.toggle_todo()
    elseif section == "Projects" then
        M.open_project_file(line)
    end
end

-- 현재 섹션을 반환하는 함수
function M.get_section()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(0, 0, current_line, false)

    for i = #lines, 1, -1 do
        local l = lines[i]
        if l:match("^# Actions") then return "Actions" end
        if l:match("^# Things") then return "Things" end
        if l:match("^# Projects") then return "Projects" end
        if l:match("^# Keep") then return "Keep" end
    end
    return nil
end

-- Actions 섹션의 todo 항목을 토글하는 함수
function M.toggle_todo()
    local line = vim.api.nvim_get_current_line()
    local new_line = ""

    if line:match("%- %[ %]") then
        new_line = line:gsub("%- %[ %]", "- [x]")
        vim.api.nvim_set_current_line(new_line)
        M.todo_reorder()
    elseif line:match("%- %[x%]") then
        new_line = line:gsub("%- %[x%]", "- [ ]")
        vim.api.nvim_set_current_line(new_line)
    end
end

function M.todo_reorder()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local action_start, action_end
    local uncomplete_todos = {}
    local complete_todos = {}

    -- 섹션을 찾고, 할 일을 uncomplete와 complete로 분류
    for i, line in ipairs(lines) do
        if line:match("^# Actions") then
            action_start = i
        elseif line:match("^# ") and action_start then
            action_end = i - 2
            break
        elseif action_start then
            if line:match("%- %[x%]") then
                table.insert(complete_todos, line)  -- 완료된 할 일
            elseif line:match("%- %[ %]") then
                table.insert(uncomplete_todos, line)  -- 미완료 할 일
            end
        end
    end

    -- 섹션 내의 변경 사항이 있을 때만 실행
    if action_start and action_end and (#uncomplete_todos > 0 or #complete_todos > 0) then
        local reordered_section = {}

        -- 미완료 할 일을 먼저 추가
        for _, todo in ipairs(uncomplete_todos) do
            table.insert(reordered_section, todo)
        end

        -- 완료된 할 일을 뒤에 추가
        for _, todo in ipairs(complete_todos) do
            table.insert(reordered_section, todo)
        end

        -- 기존 섹션 내용 제거 후 재정렬된 내용 삽입
        vim.list_extend(lines, reordered_section, action_start, action_end)
        vim.api.nvim_buf_set_lines(0, action_start, action_end , false, reordered_section)
    end
end


-- Things 섹션 항목을 Actions로 이동
function M.move_to_actions()
    M.move_to_section("Actions", "- [ ] ")
end

-- Things 섹션 항목을 Keep으로 이동
function M.move_to_keep()
    M.move_to_section("Keep", "- ")
end

-- Things 섹션 항목을 Projects로 이동
function M.move_to_projects()
    M.move_to_section("Projects", "- ")
end

-- 특정 섹션으로 항목 이동 함수
function M.move_to_section(target_section, prefix)
    local line = vim.api.nvim_get_current_line()
    local stripped_line = line:gsub("^- ", "")  -- '-' 삭제
    local new_line = prefix .. stripped_line

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local target_index

    for i, l in ipairs(lines) do
        if l:match("^# " .. target_section) then
            target_index = i
            break
        end
    end

    if target_index then
        if target_index < vim.api.nvim_win_get_cursor(0)[1] then
            -- 대상 섹션이 위에 있을 경우
            table.insert(lines, target_index + 1, new_line)
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            local current_line = vim.api.nvim_win_get_cursor(0)[1]
            vim.api.nvim_buf_set_lines(0, current_line, current_line + 1, false, {})
        else
            -- 대상 섹션이 아래에 있을 경우
            table.insert(lines, target_index + 1, new_line)
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            vim.api.nvim_del_current_line()
        end
    end
end

-- Project 항목을 클릭하여 파일 열기/생성
function M.open_project_file(line)
    local project_name = line:match("^%- (%S+)")
    if project_name then
        local file_path = utils.project_dir .. "/" .. project_name .. ".md"
        vim.cmd("edit " .. file_path)
    end
end

return M
