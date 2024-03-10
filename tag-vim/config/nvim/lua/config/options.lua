-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.maplocalleader = ","

if vim.fn.system("defaults read -g AppleInterfaceStyle") == "Dark\n" then
  vim.o.background = "dark"
else
  vim.o.background = "light"
end

-- file handling
vim.opt.autowrite = false -- disable autowrite (enabled by LazyVim)
vim.opt.swapfile = false -- don't create a swapfile
vim.opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited

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
--vim.opt.cmdheight = 1                           -- more space in the neovim command line for displaying messages
--vim.opt.showtabline = 0                         -- always show tabs
--vim.opt.showcmd = false                         -- hide (partial) command in the last line of the screen (for performance)
--vim.opt.ruler = false                           -- hide the line and column number of the cursor position
--vim.opt.numberwidth = 4                         -- minimal number of columns to use for the line number {default 4}
--vim.opt.fillchars.eob = " " -- show empty lines at the end of a buffer as ` ` {default `~`}
--vim.opt.guifont = "monospace:h17"               -- the font used in graphical neovim applications
vim.opt.listchars = {
  tab = "▸ ",
  trail = "·",
  eol = "¬",
  extends = ">",
  precedes = "<",
}
vim.opt.showbreak = "↳" -- the character to show at the start of lines that have been wrapped

-- disable netrw in favour of oil
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
