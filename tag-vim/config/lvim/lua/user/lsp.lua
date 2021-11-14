local M = {}

M.config = function()
  -- ---@usage disable automatic installation of servers
  -- lvim.lsp.automatic_servers_installation = false

  -- ---@usage Select which servers should be configured manually. Requires `:LvimCacheRest` to take effect.
  -- See the full default list `:lua print(vim.inspect(lvim.lsp.override))`
  -- vim.list_extend(lvim.lsp.override, { "pyright" })

  -- ---@usage setup a server -- see: https://www.lunarvim.org/languages/#overriding-the-default-configuration
  -- local opts = {} -- check the lspconfig documentation for a list of all possible options
  -- require("lvim.lsp.manager").setup("pylsp", opts)

  -- you can set a custom on_attach function that will be used for all the language servers
  -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
  -- lvim.lsp.on_attach_callback = function(client, bufnr)
  --   local function buf_set_option(...)
  --     vim.api.nvim_buf_set_option(bufnr, ...)
  --   end
  --   --Enable completion triggered by <c-x><c-o>
  --   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
  -- end
  -- you can overwrite the null_ls setup table (useful for setting the root_dir function)
  -- lvim.lsp.null_ls.setup = {
  --   root_dir = require("lspconfig").util.root_pattern("Makefile", ".git", "node_modules"),
  -- }
  -- or if you need something more advanced
  -- lvim.lsp.null_ls.setup.root_dir = function(fname)
  --   if vim.bo.filetype == "javascript" then
  --     return require("lspconfig/util").root_pattern("Makefile", ".git", "node_modules")(fname)
  --       or require("lspconfig/util").path.dirname(fname)
  --   elseif vim.bo.filetype == "php" then
  --     return require("lspconfig/util").root_pattern("Makefile", ".git", "composer.json")(fname) or vim.fn.getcwd()
  --   else
  --     return require("lspconfig/util").root_pattern("Makefile", ".git")(fname) or require("lspconfig/util").path.dirname(fname)
  --   end
  -- end

  -- -- set a formatter, this will override the language server formatting capabilities (if it exists)
  -- local formatters = require "lvim.lsp.null-ls.formatters"
  -- formatters.setup {
  --   { exe = "black", filetypes = { "python" } },
  --   { exe = "isort", filetypes = { "python" } },
  --   {
  --     exe = "prettier",
  --     ---@usage arguments to pass to the formatter
  --     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
  --     args = { "--print-with", "100" },
  --     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
  --     filetypes = { "typescript", "typescriptreact" },
  --   },
  -- }

  -- -- set additional linters
  -- local linters = require "lvim.lsp.null-ls.linters"
  -- linters.setup {
  --   { exe = "flake8", filetypes = { "python" } },
  --   {
  --     exe = "shellcheck",
  --     ---@usage arguments to pass to the formatter
  --     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
  --     args = { "--severity", "warning" },
  --   },
  --   {
  --     exe = "codespell",
  --     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
  --     filetypes = { "javascript", "python" },
  --   },
  -- }
end

return M
