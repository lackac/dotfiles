return {
  {
    "nvim-neorg/neorg",
    ft = "norg",
    cmd = "Neorg",
    dependencies = { "nvim-lua/plenary.nvim" },
    build = ":Neorg sync-parsers",
    opts = {
      load = {
        ["core.defaults"] = {}, -- Loads default behaviour
        ["core.completion"] = { config = { engine = "nvim-cmp", name = "[Norg]" } },
        ["core.integrations.nvim-cmp"] = {},
        ["core.concealer"] = { config = { icon_preset = "diamond" } }, -- Adds pretty icons to your documents
        ["core.keybinds"] = {
          -- https://github.com/nvim-neorg/neorg/blob/main/lua/neorg/modules/core/keybinds/keybinds.lua
          config = {
            default_keybinds = true,
            neorg_leader = "<LocalLeader>",
            hook = function(kb)
              kb.remap_key("norg", "n", "<C-Space>", kb.leader .. kb.leader)
            end,
          },
        },
        ["core.dirman"] = { -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = "~/Documents/Notes",
            },
          },
        },
        ["core.esupports.metagen"] = { config = { type = "auto", update_date = true } },
        ["core.qol.toc"] = {},
        ["core.qol.todo_items"] = {},
        ["core.looking-glass"] = {},
        ["core.presenter"] = { config = { zen_mode = "zen-mode" } },
        ["core.export"] = {},
        ["core.export.markdown"] = { config = { extensions = "all" } },
        ["core.summary"] = {},
        ["core.tangle"] = { config = { report_on_empty = false } },
        ["core.ui.calendar"] = {},
        ["core.journal"] = {
          config = {
            strategy = "flat",
            workspace = "Notes",
          },
        },
      },
    },
  },

  {
    "zk-org/zk-nvim",
    main = "zk",
    ft = "markdown",
    opts = {
      picker = "telescope",
      lsp = {
        auto_attach = {
          enabled = true,
          filetypes = { "markdown" },
        },
      },
    },
    keys = {
      {
        "<leader>nn",
        "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>",
        mode = { "n" },
        desc = "Create new Note",
      },
      { "<leader>fn", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", mode = { "n" }, desc = "Browse Notes" },
      { "<leader>nt", "<Cmd>ZkTags<CR>", mode = { "n" }, desc = "Browse Note Tags" },
      {
        "<leader>nm",
        ":'<,'>ZkMatch<CR>",
        mode = { "v" },
        desc = "Search Notes matching current visual selection",
      },

      {
        "<leader>nn",
        "<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
        desc = "Create a new note after asking for its title.",
        mode = { "n" },
        ft = "markdown",
      },
      {
        "<leader>nt",
        ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>",
        desc = "Create a new note in the same directory as the current buffer, using the current selection for title.",
        mode = { "v" },
        ft = "markdown",
      },
      {
        "<leader>nc",
        ":'<,'>ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
        desc = "Create a new note in the same directory as the current buffer, using the current selection for note content and asking for its title.",
        mode = { "v" },
        ft = "markdown",
      },
      {
        "<leader>nb",
        "<Cmd>ZkBacklinks<CR>",
        desc = "Open notes linking to the current buffer.",
        mode = { "n" },
        ft = "markdown",
      },
      {
        "<leader>nl",
        "<Cmd>ZkLinks<CR>",
        desc = "Open notes linked by the current buffer.",
        mode = { "n" },
        ft = "markdown",
      },
    },
  },

  {
    "postfen/clipboard-image.nvim",
    opts = {
      default = {
        img_dir = { "%:p:h", "assets" },
        img_dir_text = "assets",
        img_name = function()
          local mode = vim.api.nvim_get_mode().mode
          if mode == "v" then
            vim.cmd('normal! vgv"ay')
            local selection = vim.api.nvim_eval("@a")
            vim.cmd("normal! gvd")
            return selection
          else
            vim.fn.inputsave()
            local name = vim.fn.input("Image Name: ")
            vim.fn.inputrestore()
            return name
          end
        end,
        img_handler = function(img)
          vim.cmd("normal! f[")
          vim.cmd("normal! a" .. img.name)
        end,
      },
      markdown = {
        affix = "![](%s)",
      },
    },
    keys = {
      { "<leader>P", "<cmd>PasteImg<cr>", mode = { "n", "v" }, desc = "Paste Image from Clipboard" },
    },
  },
}
