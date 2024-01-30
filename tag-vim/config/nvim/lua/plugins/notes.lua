return {
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
