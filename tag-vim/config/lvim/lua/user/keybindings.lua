local M = {}

M.config = function()
  -- keymappings [view all the defaults by pressing <leader>Lk]
  lvim.keys.visual_mode["<"] = "<"
  lvim.keys.visual_mode[">"] = ">"
  -- unmap a default keymapping
  -- lvim.keys.normal_mode["<C-Up>"] = ""
  -- edit a default keymapping
  -- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

  -- Use which-key to add extra bindings with the leader-key prefix
  lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
  lvim.builtin.which_key.mappings["t"] = {
    name = "+Trouble",
    r = { "<cmd>Trouble lsp_references<cr>", "References" },
    f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
    d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
    q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
    l = { "<cmd>Trouble loclist<cr>", "LocationList" },
    w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" },
  }

  -- -- remap Explorer to 'x'
  -- lvim.builtin.which_key.mappings["x"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" }
  -- lvim.builtin.which_key.mappings["e"] = {
  --   name = "+Edit relative",
  --   w = { ":edit <C-R>=expand('%:h').'/'<cr>", "Edit in current Window" },
  --   s = { ":split <C-R>=expand('%:h').'/'<cr>", "Edit in horizontal Split" },
  --   v = { ":vsplit <C-R>=expand('%:h').'/'<cr>", "Edit in Vertical split" },
  --   t = { ":tabedit <C-R>=expand('%:h').'/'<cr>", "Edit in new Tab" },
  --   r = { ":read <C-R>=expand('%:h').'/'<cr>", "Read relative" },
  -- }

  lvim.builtin.which_key.mappings["L"]["F"] = {
    "<cmd>lua require('user.util').find_lvim_user_files()<cr>",
    "Find LunarVim User files",
  }
  lvim.builtin.which_key.mappings["L"]["G"] = {
    "<cmd>lua require('user.util').grep_lvim_user_files()<cr>",
    "Grep LunarVim User files",
  }

end

return M
