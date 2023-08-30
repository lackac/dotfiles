local Util = require("lazyvim.util")

return {
  {
    "nvim-telescope/telescope.nvim",

    -- enable faster and more capable fuzzy search with fzf
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },

    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
        file_ignore_patterns = { ".git/", "node_modules/", "vendor/" },
      },
    },

    -- mappings in LazyVim are quite comprehensive already
    -- these are just a few additions
    keys = {
      {
        "<leader>fc",
        Util.telescope("files", { cwd = vim.fn.stdpath("config"), follow = true }),
        desc = "Find Configuration Files",
      },
      { "<leader>sN", "<cmd>Telescope notify<cr>", desc = "List Notifications" },
      { "<leader>snn", "<cmd>Telescope notify<cr>", desc = "List Notifications" },
    },

    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("notify")
    end,
  },

  -- more file types for illuminate to ignore
  {
    "RRethy/vim-illuminate",
    opts = {
      filetypes_denylist = {
        "dirvish",
        "fugitive",
        "alpha",
        "NvimTree",
        "neo-tree",
        "packer",
        "neogitstatus",
        "Trouble",
        "lir",
        "Outline",
        "spectre_panel",
        "toggleterm",
        "DressingSelect",
        "TelescopePrompt",
      },
    },
  },

  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = { "s1n7ax/nvim-window-picker" },
    opts = {
      window = {
        mappings = {
          ["<C-v>"] = "open_vsplit",
          ["<C-x>"] = "open_split",
        },
      },
    },
  },

  {
    "folke/flash.nvim",
    search = {
      mode = function(str)
        return "\\<" .. str
      end,
    },
  },

  -- vim-vinegar like file explorer that lets you edit your filesystem like a normal Neovim buffer
  {
    "stevearc/oil.nvim",
    opts = {
      keymaps = {
        ["<C-h>"] = false,
        ["<C-t>"] = false,
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-x>"] = "actions.select_split",
      },
    },

    dependencies = { "nvim-tree/nvim-web-devicons" },

    keys = {
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Open parent directory",
      },
    },
  },

  -- tpope wonders
  { "tpope/vim-fugitive" }, -- git wrapper commands
  { "tpope/vim-rhubarb" }, -- GitHub extension for fugitive.vim
  { "tpope/vim-eunuch" }, -- UNIX command line helpers
  { "tpope/vim-repeat" }, -- enable repeating supported plugin maps with "."
  { "tpope/vim-unimpaired" }, -- pairs of handy bracket mappings
  { "tpope/vim-rails" }, -- Ruby on Rails power tools
  { "tpope/vim-sleuth" }, -- Detect tabstop and shiftwidth automatically

  -- miscellaneous
  { "pbrisbin/vim-mkdir" },
  { "duff/vim-scratch" },
}