local utils = require('workflow.utils')

local M = {}

local generated_number = {}

local function generate_project_id()
    local random_number
    repeat
        random_number = math.random(10, 99)
    until not generated_number[random_number]
        generated_number[random_number] = true
    return "^p" .. random_number
end

M.complete_todos = {}
M.uncomplete_todos = {}
M.project_tag = ""

-- Goals 
function M.format_goal_todos()
    local all_todos = {}
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local goal_start, goal_end = utils.serch_section("^# Project Goals")

    -- Serch project tag
    for i = 1, goal_start do
        local line = lines[i]
        if line:match("^@%w+") then
            M.project_tag = line:match("^@%w+") or ""
        end
    end

    -- Parse todos in Project Goals section
    for i = goal_start + 1, goal_end do
        local line = lines[i]
        if line:match("%- %[ %]") or line:match("%- %[x%]") then
            -- Extract components and remove them from desc
            local id = line:match('^%d+') or generate_project_id()
            local tag = line:match("#%S+") or ""
            local project = line:match("@%S+") or M.project_tag
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

            local complete
            if line:match("%- %[ %]") then
                complete = "- [ ] "
            else line:match("%- %[x%]")
                complete = "- [x] "
            end

            M.todo = {
                id = id,
                desc = desc,
                tag = tag,
                project = project,
                priority = priority,
                due = due,
                dur = dur,
                complete = complete,
                raw_line = line
            }

            table.insert(all_todos, M.todo)

            if line:match("%- %[ %]") then
                table.insert(M.uncomplete_todos, M.todo)
            else
                table.insert(M.complete_todos, M.todo)
            end

            table.insert(all_todos, { raw_line = line, is_todo = false})
        end
    end

    -- Create formatted sections
    local formatted_section = vim.list_slice(lines, 1, goal_start)
    vim.list_extend(formatted_section, M.header_lines)


    -- Add todos and non-todo lines
    for _, item in ipairs(all_todos) do
        if item.is_todo == false then
            -- Add non-To-Do lines as-is
            table.insert(formatted_section, item.raw_line)
        else
            -- Format To-Do items
        local formatted_line = string.format(
            "%s" .. "%-" .. utils.width_desc .. "s %-" .. utils.width_tag .. "s %-" .. utils.width_project .. "s %-" .. utils.width_priority .. "s %-" .. utils.width_due .. "s %-" .. utils.width_dur .. "s",
            item.complete,
            item.desc .. item.id,
            item.tag,
            item.project,
            item.priority,
            item.due,
            item.dur
        )
            table.insert(formatted_section, formatted_line)
        end
    end

    -- Add remaining lines after Project Goals section
    local remaining_lines = vim.list_slice(lines, goal_end + 1, #lines)
    vim.list_extend(formatted_section, remaining_lines)

    -- Buffer update
    vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted_section)

end

return M
