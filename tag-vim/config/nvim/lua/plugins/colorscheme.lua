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
    init = function()
      if vim.fn.system("defaults read -g AppleInterfaceStyle") == "Dark\n" then
        vim.o.background = "dark"
      else
        vim.o.background = "light"
      end
    end,
  },

  {
    "LazyVim/LazyVim",

    opts = {
      colorscheme = "solarized",
    },
  },
}
