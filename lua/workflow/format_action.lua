local utils = require('workflow.utils')
local proj = require('workflow.format_project')

local M = {}

-- 날짜 비교 함수
local function parse_date(date_str)
    local year, month, day = date_str:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
    return os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day) })
end

-- Action 섹션 정렬 및 재배치 함수
function M.format_action_todos()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local uncomplete_todos = {}
    local complete_todos = {}
    local action_start, action_end = utils.serch_section("^# Actions")

   -- Parse todos in Action section
    for i = action_start + 1, action_end do
        local line = lines[i]
        if line:match("%- %[ %]") or line:match("%- %[x%]") then
            -- Extract components and remove them from desc
            local id = line:match('^%d+') or ""
            local tag = line:match("#%S+") or ""
            local project = line:match("@%S+") or ""
            local priority = line:match("!+") or ""
            local due = line:match("%d%d%d%d%-%d%d%-%d%d") or ""
            local dur = line:match("%$%d+%a+") or ""

            local desc = line
            desc = desc:gsub("%- %[.]", "") -- Remove checkbox
                       :gsub("#%S+", "")    -- Remove tag
                       :gsub("@%S+", "")    -- Remove project
                       :gsub("!+", "")      -- Remove priority
                       :gsub("%d%d%d%d%-%d%d%-%d%d", "") -- Remove due date
                       :gsub("%$%d+%a+", "") -- Remove duration
                       :gsub("^%s+", "")    -- Trim leading spaces
                       :gsub("%s+$", "")    -- Trim trailing spaces

            local todo = {
                id = id,
                desc = desc,
                tag = tag,
                project = project,
                priority = priority,
                due = due,
                dur = dur,
                raw_line = line,
            }

            if line:match("%- %[ %]") then
                table.insert(uncomplete_todos, todo)
            else
                table.insert(complete_todos, todo)
            end
        end
    end

    -- Add project todo to action
    table.insert(uncomplete_todos, proj.uncomplete_todos)

   -- Sort function
    local function sort_todos(todos)
        table.sort(todos, function(a, b)
            local a_due = a.due ~= "" and parse_date(a.due) or math.huge
            local b_due = b.due ~= "" and parse_date(b.due) or math.huge

            if a_due ~= b_due then
                return a_due < b_due
            else
                local priority_order = { ["!!!"] = 3, ["!!"] = 2, ["!"] = 1 }
                local a_priority = priority_order[a.priority] or 0
                local b_priority = priority_order[b.priority] or 0
                return a_priority > b_priority
            end
        end)
    end

    -- uncomplete와 complete 정렬
    sort_todos(uncomplete_todos)
    sort_todos(complete_todos)

    -- Create formatted sections
    local formatted_section = vim.list_slice(lines, 1, action_start)
    vim.list_extend(formatted_section, utils.header_lines)

    -- 정렬된 uncomplete todos 추가
    for _, todo in ipairs(uncomplete_todos) do
        local formatted_line = string.format(
            "- [ ] " .. "%-" .. utils.width_desc .. "s %-" .. utils.width_tag .. "s %-" .. utils.width_project .. "s %-" .. utils.width_priority .. "s %-" .. utils.width_due .. "s %-" .. utils.width_dur .. "s",
            todo.desc .. todo.id, todo.tag, todo.project, todo.priority, todo.due, todo.dur)
        table.insert(formatted_section, formatted_line)
    end

    -- 정렬된 complete todos 추가
    if #complete_todos > 0 then
        for _, todo in ipairs(complete_todos) do
            local formatted_line = string.format(
            "- [x] " .. "%-" .. utils.width_desc .. "s %-" .. utils.width_tag .. "s %-" .. utils.width_project .. "s %-" .. utils.width_priority .. "s %-" .. utils.width_due .. "s %-" .. utils.width_dur .. "s",
            todo.desc .. todo.id, todo.tag, todo.project, todo.priority, todo.due, todo.dur)
            table.insert(formatted_section, formatted_line)
        end
    end
    table.insert(formatted_section, "")

    -- Add remaining lines after Action section
    local remaining_lines = vim.list_slice(lines, action_end + 1, #lines)
    vim.list_extend(formatted_section, remaining_lines)

    -- Buffer update
    vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted_section)
end

return M
