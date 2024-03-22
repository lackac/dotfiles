local Util = require("lazyvim.util")

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "debugloop/telescope-undo.nvim",
      },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
        file_ignore_patterns = { ".git/", "node_modules/", "vendor/" },
      },
      extensions = {
        undo = {},
      },
    },
    -- mappings in LazyVim are quite comprehensive already
    -- these are just a few additions
    keys = {
      -- override LazyVim heuristic of using git_files when in a git repo
      -- rg based find_files ignores are more precise and faster
      { "<leader><space>", Util.telescope("find_files"), desc = "Find Files (root dir)" },
      { "<leader>ff", Util.telescope("find_files"), desc = "Find Files (root dir)" },
      { "<leader>fF", Util.telescope("find_files", { cwd = false }), desc = "Find Files (cwd)" },

      -- override config files search to follow symlinks
      {
        "<leader>fc",
        Util.telescope("files", { cwd = vim.fn.stdpath("config"), follow = true }),
        desc = "Find Configuration Files",
      },

      { "<leader>sN", "<cmd>Telescope notify<cr>", desc = "List Notifications" },
      { "<leader>snn", "<cmd>Telescope notify<cr>", desc = "List Notifications" },
      { "<leader>U", "<cmd>Telescope undo<cr>", desc = "Undo tree" },

      -- alternative keybinds for git related functions to avoid conflict with neogit
      { "<leader>gc", false },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status (Telescope)" },
      { "<leader>gS", "<cmd>Telescope git_stash<CR>", desc = "stash (Telescope)" },
      { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "branches (Telescope)" },
      { "<leader>gl", "<cmd>Telescope git_commits<CR>", desc = "log (Telescope)" },
      { "<leader>gL", "<cmd>Telescope git_bcommits<CR>", desc = "file history (Telescope)" },
    },

    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("notify")
      telescope.load_extension("undo")
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
        "oil",
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
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    opts = {
      kind = "auto",
      commit_select_view = {
        kind = "auto",
      },
      log_view = {
        kind = "auto",
      },
      reflog_view = {
        kind = "auto",
      },
      signs = {
        -- { CLOSED, OPENED }
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "status" },
      { "<leader>gc", "<cmd>Neogit commit<CR>", desc = "commit" },
      { "<leader>gp", "<cmd>Neogit pull<CR>", desc = "pull" },
      { "<leader>gP", "<cmd>Neogit push<CR>", desc = "push" },
    },
  },

  { "folke/flash.nvim", enabled = false },

  {
    "3rd/image.nvim",
    opts = {
      tmux_show_only_in_active_window = true,
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
  { "tpope/vim-eunuch" }, -- UNIX command line helpers
  { "tpope/vim-repeat" }, -- enable repeating supported plugin maps with "."
  { "tpope/vim-rails" }, -- Ruby on Rails power tools
  { "tpope/vim-sleuth" }, -- Detect tabstop and shiftwidth automatically

  -- rewrites of tpope plugins in lua
  { "tummetott/unimpaired.nvim" }, -- pairs of handy bracket mappings

  -- miscellaneous
  { "duff/vim-scratch" },
}
