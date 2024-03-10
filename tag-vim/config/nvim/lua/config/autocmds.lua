-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "qf", "help", "man", "lspinfo", "spectre_panel" },
  callback = function()
    vim.cmd([[
      nnoremap <silent> <buffer> q :close<CR>
      set nobuflisted
    ]])
  end,
})

vim.cmd("autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif")

-- don't use the command line window, so this effectively disables it and with that the annoying
-- opening of it when pressing 'q:' accidentally
vim.api.nvim_create_autocmd({ "CmdWinEnter" }, {
  callback = function()
    vim.cmd("quit")
  end,
})

-- this is to fix bug: https://github.com/folke/which-key.nvim/issues/476
vim.api.nvim_create_autocmd("FileType", {
  desc = "Set up neorg Which-Key descriptions",
  group = vim.api.nvim_create_augroup("neorg_mapping_descriptions", { clear = true }),
  pattern = "norg",
  callback = function(args)
    local wk = require("which-key")
    vim.keymap.set("n", "<LocalLeader>", function()
      wk.show(vim.g.maplocalleader)
    end, { buffer = true })
    wk.register({
      i = { name = "insert" },
      l = { name = "lists" },
      m = { name = "modes" },
      n = { name = "notes" },
      t = { name = "todos" },
    }, { prefix = "<LocalLeader>", buffer = args.buf })
  end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function()
    local line_count = vim.api.nvim_buf_line_count(0)
    if line_count >= 5000 then
      vim.cmd("IlluminatePauseBuf")
    end
  end,
})

-- workaround for exit code 134 when nvim is invoked as editor by another porcess (e.g. zk)
-- https://old.reddit.com/r/neovim/comments/14bcfmb/nonzero_exit_code/
vim.api.nvim_create_autocmd({ "VimLeave" }, {
  callback = function()
    vim.cmd("sleep 10m")
  end,
})
