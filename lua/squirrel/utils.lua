local api = vim.api
local group = api.nvim_create_augroup("Squirrel", {})
local M = {}

M.key_iter = {
    keys = "etovxqpdygfzcsuran",
    cnt = 1,
}
function M.key_iter:at(n)
    n = (n == 0) and #self.keys or n
    return self.keys:sub(n, n)
end
function M.key_iter:take()
    local res, cnt, len = "", self.cnt, #self.keys
    while cnt ~= 0 do
        res = self:at(cnt % len) .. res
        cnt = math.ceil(cnt / len) - 1
    end
    self.cnt = self.cnt + 1
    return res
end
function M.key_iter:reset()
    self.cnt = 1
end

M.collect_children_on_line = function(node, linenr)
    if node:child_count() == 0 then
        local srow, scol, erow, ecol = node:range()
        -- on the current line and not too small
        return (srow == linenr and erow == linenr and ecol - scol ~= 1) and { node } or {}
    end
    local result = {}
    for child, _ in node:iter_children() do
        vim.tbl_map(function(c)
            if not vim.tbl_contains(result, c) then
                table.insert(result, c)
            end
        end, M.collect_children_on_line(child, linenr))
    end
    return result
end

M.collect_visible_children = function(node, linenr, height)
    if node:child_count() == 0 then
        local srow, scol, erow, ecol = node:range()
        local upperbound, lowerbound = linenr, linenr + height
        -- stylua: ignore
        return (
            ((srow < lowerbound and srow > upperbound) or (erow < lowerbound and erow > upperbound)) -- visible
            and (ecol - scol > 2) -- and not too small
        ) and { node } or {}
    end
    local result = {}
    for child, _ in node:iter_children() do
        vim.tbl_map(function(c)
            if not vim.tbl_contains(result, c) then
                table.insert(result, c)
            end
        end, M.collect_visible_children(child, linenr, height))
    end
    return result
end

M.register_cleanup = function()
    api.nvim_create_autocmd("ModeChanged", {
        group = group,
        once = true,
        callback = function(opts)
            M.key_iter:reset()
            for _, m in ipairs(opts.data.marks) do
                api.nvim_buf_del_extmark(0, opts.data.ns, m.id)
            end
            opts.data.marks = {}
        end,
    })
end

M.cleanup = function(ns, marks)
    api.nvim_exec_autocmds("ModeChanged", {
        group = group,
        data = {
            ns = ns,
            marks = marks,
        },
    })
end

return M
