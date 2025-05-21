return {
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
    "folke/snacks.nvim",
    opts = {
      indent = {
        indent = { char = "┊" },
      },
    },
  },
}
