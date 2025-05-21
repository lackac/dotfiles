-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- don't use the command line window, so this effectively disables it and with that the annoying
-- opening of it when pressing 'q:' accidentally
vim.api.nvim_create_autocmd({ "CmdWinEnter" }, {
  callback = function()
    vim.cmd("quit")
  end,
})

-- workaround for exit code 134 when nvim is invoked as editor by another porcess (e.g. zk)
-- https://old.reddit.com/r/neovim/comments/14bcfmb/nonzero_exit_code/
vim.api.nvim_create_autocmd({ "VimLeave" }, {
  callback = function()
    vim.cmd("sleep 10m")
  end,
})
