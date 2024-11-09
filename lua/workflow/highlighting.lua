local M = {}

-- Syntax highlighting
function M.workflow_highlighting()
    -- Create a new group for custom workflow highlighting
    local group = vim.api.nvim_create_augroup("WorkflowHighlight", { clear = true })

    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.workflow",
        group = group,
        callback = function()
            vim.cmd [[
            syntax match WorkflowHeader /# \w\+/
            highlight WorkflowHeader ctermfg=DarkYellow guifg=#FFA500
            ]]
        end,
    })


    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.workflow",
        group = group,
        callback = function()
            vim.cmd [[
        syntax match WorkflowPriority /!\{1,3}/
        highlight WorkflowPriority ctermfg=LightRed guifg=#FF6347
        ]]
        end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.workflow",
        group = group,
        callback = function()
            vim.cmd [[
        syntax match WorkflowTag /#\w\+/
        highlight WorkflowTag  ctermfg=LightYellow guifg=#FFD700
        ]]
        end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.workflow",
        group = group,
        callback = function()
            vim.cmd [[
            syntax match WorkflowProject /@\w\+/
            highlight WorkflowProject ctermfg=Green guifg=#00FF00
            ]]
        end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.workflow",
    group = group,
    callback = function()
        vim.cmd [[
        syntax match WorkflowDue /due:\d\{4}-\d\{2}-\d\{2}/
        highlight WorkflowDue ctermfg=LightBlue guifg=#4682B4
        ]]
    end,
})

end

return M
