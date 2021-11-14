local M = {}

M.config = function()
  -- set a formatter if you want to override the default lsp one (if it exists)
  -- lvim.lang.python.formatters = {
  --   {
  --     exe = "black",
  --     args = {}
  --   }
  -- }
  -- set an additional linter
  -- lvim.lang.python.linters = {
  --   {
  --     exe = "flake8",
  --     args = {}
  --   }
  -- }
end

return M
