return {
  {
    "L3MON4D3/LuaSnip",
    -- disable key mappings set by LazyVim and handle them as cmp mappings
    keys = function()
      return {}
    end,
  },

  -- configure supertab and some other mappings
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lua",
    },
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require("cmp")
      local luasnip = require("luasnip")

      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "nvim_lua" } }))

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<CR>"] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
          -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
          -- they way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })

      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }
    end,
  },

  -- use autopairs instead of mini.pairs
  { "echasnovski/mini.pairs", enabled = false },
  {
    "windwp/nvim-autopairs",
    opts = {
      check_ts = true, -- treesitter integration
      disable_filetype = { "TelescopePrompt" },
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
        java = false,
      },

      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0, -- Offset from pattern match
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp_status_ok, cmp = pcall(require, "cmp")
      if cmp_status_ok then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({}))
      end
    end,
  },

  -- use kylechui/nvim-surround instead of mini.surround
  { "echasnovski/mini.surround", enabled = false },
  { "kylechui/nvim-surround", config = true },

  -- use numToStr/Comment instead of mini.comment
  { "echasnovski/mini.comment", enabled = false },
  {
    "numToStr/Comment.nvim",
    config = true,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufRead",
    keys = {
      {
        "[c",
        function()
          require("treesitter-context").go_to_context()
        end,
        desc = "Jump to [c]ontext",
        silent = true,
      },
    },
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
