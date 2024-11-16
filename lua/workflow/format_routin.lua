
local utils = require('workflow.utils')

local M = {}

-- 날짜 문자열 생성 함수
local function get_current_date()
    return os.date("%Y-%m-%d")
end

function M.format_routin_todos()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local routin_start, routin_end = utils.serch_section("^# Routins")
    local uncomplete_todos = {}
    local complete_todos = {}
    local current_date = get_current_date()

    -- Parsing todos in Routine section
    for i = routin_start + 1, routin_end do
        local line = lines[i]
        if line:match("%- %[ %]") or line:match("%- %[x%]") then
            local completed_date = line:match("%d%d%d%d%-%d%d%-%d%d")

            local desc = line
            desc = desc:gsub("%- %[.]", "")
                       :gsub("%d%d%d%d%-%d%d%-%d%d", "")
                       :gsub("^%s+", "")
                       :gsub("%s+$", "")

            local todo = {
                desc = desc,
                completed_date = completed_date
            }

            -- 완료 상태 확인
            if line:match("%- %[x%]") then
                if completed_date == current_date then
                    table.insert(complete_todos, todo)
                else
                    -- 완료 날짜가 현재 날짜와 다르면 uncomplete로 이동
                    table.insert(uncomplete_todos, {
                    desc = desc,
                    completed_date = nil -- 날짜 없음
                    })
                end
            else
                table.insert(uncomplete_todos, todo)
            end
        end
    end

    -- 정렬된 섹션 작성
    local formatted_section = vim.list_slice(lines, 1, routin_start)

    -- 정렬된 uncomplete todos 추가
    for _, todo in ipairs(uncomplete_todos) do
        local formatted_line = string.format("- [ ] %-25s",
            todo.desc)
        table.insert(formatted_section, formatted_line)
    end

    -- 정렬된 complete todos 추가
    for _, todo in ipairs(complete_todos) do
        local formatted_line = string.format("- [x] %-25s %-11s",
            todo.desc, todo.completed_date or "")
        table.insert(formatted_section, formatted_line)
    end
    table.insert(formatted_section, "")

    -- Routin 섹션 이후 나머지 줄 추가
    local remaining_lines = vim.list_slice(lines, routin_end + 1, #lines)
    vim.list_extend(formatted_section, remaining_lines)

    -- 버퍼 업데이트
    vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted_section)
end

return M
