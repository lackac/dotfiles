local M = {}

local user_path = os.getenv "HOME" .. "/.config/lvim/"

function M.find_lvim_user_files(opts)
  opts = opts or {}
  local themes = require "telescope.themes"
  local theme_opts = themes.get_ivy {
    previewer = false,
    sorting_strategy = "ascending",
    layout_strategy = "bottom_pane",
    layout_config = {
      height = 5,
      width = 0.5,
    },
    prompt = ">> ",
    prompt_title = "~ LunarVim User files ~",
    cwd = user_path,
  }
  opts = vim.tbl_deep_extend("force", theme_opts, opts)
  require("telescope.builtin").find_files(opts)
end

function M.grep_lvim_user_files(opts)
  opts = opts or {}
  local themes = require "telescope.themes"
  local theme_opts = themes.get_ivy {
    sorting_strategy = "ascending",
    layout_strategy = "bottom_pane",
    prompt = ">> ",
    prompt_title = "~ search LunarVim User files ~",
    cwd = user_path
  }
  opts = vim.tbl_deep_extend("force", theme_opts, opts)
  require("telescope.builtin").live_grep(opts)
end

return M
