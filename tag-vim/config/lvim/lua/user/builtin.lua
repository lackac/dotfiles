local M = {}

M.config = function()
  -- User Config for predefined plugins
  lvim.builtin.dashboard.active = true
  lvim.builtin.terminal.active = true

  lvim.builtin.nvimtree.setup.view.side = "left"
  lvim.builtin.nvimtree.show_icons.git = 0

  -- if you don't want all the parsers change this to a table of the ones you want
  lvim.builtin.treesitter.ensure_installed = {
    "bash",
    "beancount",
    "c",
    "clojure",
    "cpp",
    "css",
    "dockerfile",
    "elixir",
    "elm",
    "erlang",
    "go",
    "graphql",
    "hcl",
    "heex",
    "html",
    "java",
    "javascript",
    "json",
    "ledger",
    "lua",
    "python",
    "ruby",
    "rust",
    "scss",
    "toml",
    "typescript",
    "vim",
    "yaml",
    "zig",
  }
  lvim.builtin.treesitter.ignore_install = { "haskell" }
  lvim.builtin.treesitter.highlight.enabled = true

  lvim.builtin.telescope.defaults.file_ignore_patterns = { "node_modules/", "vendor/" }
end

return M
