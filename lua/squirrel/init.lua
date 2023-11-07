vim.keymap.set({ "n", "x" }, "gaa", require("squirrel.hop").hop_linewise)
vim.keymap.set({ "n", "x" }, "ga", require("squirrel.hop").hop)
vim.keymap.set({ "n", "x" }, "gee", function()
    require("squirrel.hop").hop_linewise({
        head = false,
        tail = true,
    })
end)
vim.keymap.set({ "n", "x" }, "ge", function()
    require("squirrel.hop").hop({
        head = false,
        tail = true,
    })
end)
