local M = {}
local marks = {}
local api, ts = vim.api, vim.treesitter
local ns = api.nvim_create_namespace("Squirrel")
local utils = require("xsh.squirrel.utils")
local key_iter, cleanup = utils.key_iter, utils.cleanup

local function extmark_opts(k, id)
    return {
        id = id,
        priority = 1000,
        hl_mode = "combine",
        virt_text_pos = "overlay",
        hl_eol = true,
        virt_text = { { k, "Search" } },
    }
end

local function await_input()
    local input = vim.fn.getcharstr()
    if #marks == 0 or string.byte(input) == 27 then
        -- exit and cleanup
        return cleanup(ns, marks)
    end
    local prefix_match, match = 0, nil
    for i = #marks, 1, -1 do
        local mark = marks[i]
        if mark.key:sub(1, 1) ~= input then
            table.remove(marks, i)
            api.nvim_buf_del_extmark(0, ns, mark.id)
        elseif mark.key == input then
            -- matched
            prefix_match = prefix_match + 1
            match = mark
            api.nvim_win_set_cursor(0, match.pos)
            api.nvim_buf_del_extmark(0, ns, mark.id)
        else
            prefix_match = prefix_match + 1
            mark.key = mark.key:sub(2)
        end
    end
    if prefix_match == 1 then
        ---@diagnostic disable-next-line: undefined-field, need-check-nil
        return cleanup(ns, marks)
    end
    if #marks == 0 then
        cleanup(ns, marks)
        api.nvim_input(input)
        return
    end
    -- if we haven't returned yet, do a redraw
    for _, mark in ipairs(marks) do
        api.nvim_buf_set_extmark(0, ns, mark.pos[1] - 1, mark.pos[2], extmark_opts(mark.key, mark.id))
    end
    local timer = vim.uv.new_timer()
    timer:start(0, 0, vim.schedule_wrap(await_input))
end

local function draw_and_store(row, col)
    local key = key_iter:take()
    table.insert(marks, {
        pos = { row + 1, col },
        id = api.nvim_buf_set_extmark(0, ns, row, col, extmark_opts(key)),
        key = key,
    })
end

M.hop_linewise = function(opts)
    local opt = opts or {
        head = true,
        tail = false,
    }
    if not pcall(ts.get_parser) or (not opt.head and not opt.tail) then
        -- no parser
        return
    end
    local linenr = api.nvim_win_get_cursor(0)[1] - 1
    local node = ts.get_node({
        pos = {
            linenr,
            #(api.nvim_get_current_line()):match("^%s*"),
        },
    })
    assert(node)
    local s, _, e, _ = node:range()
    -- get all smallest nodes on the current line
    while s == linenr and e == linenr do
        node = node:parent()
        s, _, e, _ = node:range()
    end
    local targets = utils.collect_children_on_line(node, linenr)
    -- draw extmarks
    for _, target in ipairs(targets) do
        local srow, scol, erow, ecol = target:range()
        if opt.head then
            draw_and_store(srow, scol)
        end
        if opt.tail then
            draw_and_store(erow, ecol)
        end
    end
    utils.register_cleanup()
    vim.schedule(await_input)
end

M.hop = function(opts)
    local opt = opts or {
        head = true,
        tail = false,
    }
    if not pcall(ts.get_parser) or (not opt.head and not opt.tail) then
        -- no parser
        return
    end
    local linenr = vim.fn.winsaveview().topline - 1
    local height = api.nvim_win_get_height(0)
    local node = ts.get_node({
        pos = {
            linenr,
            #(api.nvim_get_current_line()):match("^%s*"),
        },
    })
    assert(node)
    while node:parent() do
        node = node:parent()
    end
    local targets = utils.collect_visible_children(node, linenr, height)
    -- draw extmarks
    for _, target in ipairs(targets) do
        local srow, scol, erow, ecol = target:range()
        if opt.head then
            draw_and_store(srow, scol)
        end
        if opt.tail then
            draw_and_store(erow, ecol)
        end
    end
    utils.register_cleanup()
    vim.schedule(await_input)
end

return M
