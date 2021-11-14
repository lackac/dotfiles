local M = {}

M.config = function()

  lvim.plugins = {
    { "junegunn/vim-easy-align",
      config = function()
        vim.cmd [[
          nmap ga <Plug>(EasyAlign)
          xmap ga <Plug>(EasyAlign)
        ]]
      end
    },
    { "tpope/vim-endwise" },                            -- automatically insert end in Ruby
    { "tpope/vim-eunuch" },                             -- UNIX command wrappers (e.g. :Rename)
    { "terryma/vim-expand-region" },                    -- visually select increasingly larger regions
    { "michaeljsmith/vim-indent-object" },              -- allow operations at the indent level
    { "pbrisbin/vim-mkdir" },                           -- automatically create any non-existent directories before writing the buffer
    { "tpope/vim-rails",
      cmd = { "Eview", "Econtroller", "Emodel", "Smodel", "Sview", "Scontroller",
              "Vmodel", "Vview", "Vcontroller", "Tmodel", "Tview", "Tcontroller",
              "Rails", "Generate", "Runner", "Extract" }
    },
    { "tpope/vim-repeat" },
    { "duff/vim-scratch" },
    { "ishan9299/nvim-solarized-lua" },
    { "tpope/vim-surround", keys = {"c", "d", "y"} },
    { "christoomey/vim-tmux-navigator", keys = {"<C-h>", "<C-j>", "<C-k>", "<C-l>"} },
    { "folke/trouble.nvim", cmd = "TroubleToggle" },
    { "tpope/vim-unimpaired" },
  }

end

return M
