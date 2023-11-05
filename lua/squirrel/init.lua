vim.keymap.set({ "n", "x" }, "gaa", require("xsh.squirrel.hop").hop_linewise)
vim.keymap.set({ "n", "x" }, "ga", require("xsh.squirrel.hop").hop)
vim.keymap.set({ "n", "x" }, "ge", function()
    require("xsh.squirrel.hop").hop_linewise({
        head = false,
        tail = true,
    })
end)
vim.keymap.set({ "n", "x" }, "gee", function()
    require("xsh.squirrel.hop").hop({
        head = false,
        tail = true,
    })
end)
