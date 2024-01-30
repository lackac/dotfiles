-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local del = vim.keymap.del

-- using numToStr/Navigator.nvim for this
del("n", "<C-h>")
del("n", "<C-j>")
del("n", "<C-k>")
del("n", "<C-l>")
del("n", "<C-Up>")
del("n", "<C-Down>")
del("n", "<C-Left>")
del("n", "<C-Right>")

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

-- delete conflicting keymaps coming from LazyVim
del("n", "<leader>fn")

-- navigating between tmux panes and vim windows
-- leave these here; for some reason these don't work for lazy loading the navigator plugin
map({ "n", "t" }, "<C-h>", "<cmd>NavigatorLeft<cr>")
map({ "n", "t" }, "<C-l>", "<cmd>NavigatorRight<cr>")
map({ "n", "t" }, "<C-k>", "<cmd>NavigatorUp<cr>")
map({ "n", "t" }, "<C-j>", "<cmd>NavigatorDown<cr>")
map({ "n", "t" }, "<C-Left>", "<cmd>NavigatorLeft<cr>")
map({ "n", "t" }, "<C-Right>", "<cmd>NavigatorRight<cr>")
map({ "n", "t" }, "<C-Up>", "<cmd>NavigatorUp<cr>")
map({ "n", "t" }, "<C-Down>", "<cmd>NavigatorDown<cr>")

-- Clear highlights
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Better paste
map("v", "p", '"_dP')
