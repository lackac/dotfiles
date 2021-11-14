--[[ TODO
- [ ] port used mappings
- [ ] port used plugins
- [ ] review builtin plugins and their settings
]]
-- general
lvim.leader = "space"
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.lint_on_save = true
lvim.line_wrap_cursor_movement = false

lvim.colorscheme = "solarized"
vim.o.background = "light"

-- vim options
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 5
vim.opt.numberwidth = 2

-- inspect helper
function _G.inspect(...)
  local objects = vim.tbl_map(vim.inspect, {...})
  print(unpack(objects))
  return ...
end

require("user.keybindings").config()
require("user.builtin").config()
require("user.lsp").config()
require("user.lang").config()
require("user.plugins").config()
require("user.autocommands").config()
