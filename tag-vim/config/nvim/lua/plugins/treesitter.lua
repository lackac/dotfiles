return {
  {
    "nvim-treesitter/nvim-treesitter",
    keys = function()
      return {
        { "<c-s>", desc = "Increment selection" },
        { "<C-S-s>", desc = "Schrink selection", mode = "x" },
      }
    end,
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "css",
        "diff",
        "eex",
        "elixir",
        "erlang",
        "go",
        "hcl",
        "heex",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "ruby",
        "scss",
        "sql",
        "terraform",
        "toml",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      indent = { enable = true, disable = { "yaml", "ruby" } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-s>",
          node_incremental = "<C-s>",
          scope_incremental = "<nop>",
          node_decremental = "<C-S-s>",
        },
      },
      autopairs = {
        enable = true,
      },
      endwise = {
        enable = true,
      },
    },
  },
}
