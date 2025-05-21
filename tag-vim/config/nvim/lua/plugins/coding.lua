return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.completion = { list = { selection = { preselect = false, auto_insert = true } } }
      opts.keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      }
    end,
  },

  { "kylechui/nvim-surround", config = true },

  -- align text interactively
  {
    "echasnovski/mini.align",
    version = false,
    config = true,
  },

  -- indent objects based on treesitter (replacement of mini.indentscope functionality)
  {
    "kiyoon/treesitter-indent-object.nvim",
    keys = {
      { "ai", mode = { "x", "o" } },
      { "aI", mode = { "x", "o" } },
      { "ii", mode = { "x", "o" } },
      { "iI", mode = { "x", "o" } },
    },
    config = function()
      require("treesitter_indent_object").setup()
      local indent_object = require("treesitter_indent_object.textobj")

      -- select context-aware indent
      vim.keymap.set({ "x", "o" }, "ai", indent_object.select_indent_outer)
      -- ensure selecting entire line (or just use Vai)
      vim.keymap.set({ "x", "o" }, "aI", function()
        indent_object.select_indent_outer(true)
      end)
      -- select inner block (only if block, only else block, etc.)
      vim.keymap.set({ "x", "o" }, "ii", indent_object.select_indent_inner)
      -- select entire inner range (including if, else, etc.)
      vim.keymap.set({ "x", "o" }, "iI", function()
        indent_object.select_indent_inner(true)
      end)
    end,
  },

  -- add "end" in Ruby, Vimscript, Lua, etc.
  { "RRethy/nvim-treesitter-endwise" },
}
