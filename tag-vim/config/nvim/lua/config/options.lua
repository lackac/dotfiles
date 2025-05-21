-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.maplocalleader = ","

-- Disable Snacks animations
vim.g.snacks_animate = false

-- file handling
vim.opt.autowrite = false -- disable autowrite (enabled by LazyVim)

-- editing
vim.opt.linebreak = true -- line break behaviour when wrap is on
vim.opt.whichwrap:append("<,>,[,],h,l") -- keys allowed to move to the previous/next line when the beginning/end of line is reached

-- don't use the system clipboard implicitly
vim.opt.clipboard = ""

-- set terminal window title
vim.opt.title = true
vim.opt.titlestring = 'nvim - %{expand("%:~")}'

-- searching
vim.opt.hlsearch = true -- highlight all matches on previous search pattern

-- display
vim.opt.listchars = {
  tab = "▸ ",
  trail = "·",
  --eol = "¬",
  extends = ">",
  precedes = "<",
}
vim.opt.showbreak = "↳" -- the character to show at the start of lines that have been wrapped

