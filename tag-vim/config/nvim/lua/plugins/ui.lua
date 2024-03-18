return {
  {
    "folke/zen-mode.nvim",
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        lualine_y = {
          { "progress", padding = { left = 1, right = 1 } },
        },
        lualine_z = {
          { "location", padding = { left = 1, right = 1 } },
        },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "┊" },
    },
  },

  -- part of mini.indentscope is already implemented in indent-blankline without
  -- the annoying animation and the indent object is brought in from kiyoon in
  -- editor.lua
  { "echasnovski/mini.indentscope", enabled = false },
}
