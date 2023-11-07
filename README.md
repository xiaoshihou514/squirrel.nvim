# 🐿️ squirrel.nvim

_A small squirrel jumping around the syntax tree!_

https://github.com/xiaoshihou514/squirrel.nvim/assets/108414369/c8b53e88-459f-4f80-b927-4a8eea7d66a4

## Features

- Small and lightweight
- Jump to the start/end of treesitter nodes
- Linewise jump + jump to any visible spot

## Installation

Install like any other plugin

```
"xiaoshihou514/squirrel.nvim"
```

## Keymaps

The following are already mapped on load, you can also remap it to whatever you want

```lua
-- jump to start of any node on the current line
vim.keymap.set({ "n", "x" }, "gaa", require("squirrel.hop").hop_linewise)
-- jump to start of any visible node
vim.keymap.set({ "n", "x" }, "ga", require("squirrel.hop").hop)
-- jump to end of any node on the current line
vim.keymap.set({ "n", "x" }, "gee", function()
    require("squirrel.hop").hop_linewise({
        head = false,
        tail = true,
    })
end)
-- jump to end of any visible node
vim.keymap.set({ "n", "x" }, "ge", function()
    require("squirrel.hop").hop({
        head = false,
        tail = true,
    })
end)
```

If you want, you can also jump to any start _or_ end of nodes

```lua
require("squirrel.hop").hop_linewise({ head = true, tail = true })
```

## Configuration

Nonexistent, probably won't be one
