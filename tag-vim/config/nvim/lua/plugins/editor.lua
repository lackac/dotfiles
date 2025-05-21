return {
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
    config = function()
      require("neo-tree").setup({
        filesystem = {
          commands = {
            avante_add_files = function(state)
              local node = state.tree:get_node()
              local filepath = node:get_id()
              local relative_path = require("avante.utils").relative_path(filepath)

              local sidebar = require("avante").get()

              local open = sidebar:is_open()
              -- ensure avante sidebar is open
              if not open then
                require("avante.api").ask()
                sidebar = require("avante").get()
              end

              sidebar.file_selector:add_selected_file(relative_path)

              -- remove neo tree buffer
              if not open then
                sidebar.file_selector:remove_selected_file("neo-tree filesystem [1]")
              end
            end,
          },
          window = {
            mappings = {
              ["oa"] = "avante_add_files",
            },
          },
        },
      })
    end,
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
