-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local del = vim.keymap.del

-- Line moving keymaps are annoying when you exit insert mode and try to move up/down immediately after (ESC+j/k is same keycode as Alt-j/k)
del("n", "<A-j>")
del("n", "<A-k>")
del("i", "<A-j>")
del("i", "<A-k>")
del("v", "<A-j>")
del("v", "<A-k>")

-- preferring using repeat on visual indent instead of staying in visual
del("v", "<")
del("v", ">")

-- Clear highlights
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Better paste
map("v", "p", '"_dP')
