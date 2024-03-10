return {
  {
    "maxmx03/solarized.nvim",
    opts = {
      highlights = {
        ["@markup.strong"] = { bold = true },
        ["Underlined"] = { underline = true },
        ["illuminatedWord"] = { link = "LspReferenceText" },
      },
    },
  },

  {
    "LazyVim/LazyVim",

    opts = {
      colorscheme = "solarized",
    },
  },
}
