local utils = require('workflow.utils')
local collect = require('workflow.collect')
local section = require('workflow.section')
local highlighting = require('workflow.highlighting')

-- Command
local command = vim.api.nvim_create_user_command
command("AddThing", function(opts) collect.add_thing(opts.args) end, { nargs = 1 })
command("OpenInbox", function() vim.cmd("vsplit " .. utils.inbox_file) end, {})

command("HandleEnter", function() section.handle_enter() end, {})
command("MoveToActions", function() section.move_to_actions() end, {})
command("MoveToKeep", function() section.move_to_keep() end, {})
command("MoveToProjects", function() section.move_to_projects() end, {})

-- Keymap
local buf_map = vim.api.nvim_buf_set_keymap
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map("n", "<leader>at", ":AddThing ", opts)
map("n", "<leader>i", ":OpenInbox<CR>", opts)

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*" .. utils.workflow_ext,
    callback = function()
        buf_map(0, "n", "<CR>", ":HandleEnter<CR>", opts)
        buf_map(0, "n", "<leader>a", ":MoveToActions<CR>", opts)
        buf_map(0, "n", "<leader>k", ":MoveToKeep<CR>", opts)
        buf_map(0, "n", "<leader>p", ":MoveToProjects<CR>", opts)
    end,
})

local content = {
    "# Actions",
    "",
    "# Things",
    "",
    "# Projects",
    "",
    "# Keep",
}

utils.create_file("inbox", content)

highlighting.workflow_highlighting()

