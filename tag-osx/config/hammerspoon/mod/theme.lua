local module = {}
local log = hs.logger.new("theme", "debug")
local rgb = require("ext.utils").rgb

module.applyTheme = function(theme)
  -- set hs console theme
  hs.console.darkMode(theme == "dark")
  if hs.console.darkMode() then
    hs.console.windowBackgroundColor(rgb(7, 54, 66))
    hs.console.outputBackgroundColor(rgb(0, 43, 54))
    hs.console.inputBackgroundColor(rgb(0, 43, 54))
    hs.console.consolePrintColor(rgb(211, 54, 130))
    hs.console.consoleResultColor(rgb(38, 132, 210))
    hs.console.consoleCommandColor(rgb(133, 53, 0))
  else
    hs.console.windowBackgroundColor(rgb(238, 232, 213))
    hs.console.outputBackgroundColor(rgb(253, 246, 227))
    hs.console.inputBackgroundColor(rgb(253, 246, 227))
    hs.console.consolePrintColor(rgb(211, 54, 130))
    hs.console.consoleResultColor(rgb(38, 132, 210))
    hs.console.consoleCommandColor(rgb(133, 53, 0))
  end

  local runtimeDir = os.getenv("XDG_RUNTIME_DIR") or os.getenv("HOME") .. "/Library/Caches/TemporaryItems/runtime"
  local configDir = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"

  -- set lazygit theme
  local lazygitConfigDir = configDir .. "/lazygit/"
  local lazygitTheme = lazygitConfigDir .. "theme.yml"
  local symlinkAttrs = hs.fs.symlinkAttributes(lazygitTheme)
  if symlinkAttrs then
    os.remove(lazygitTheme)
  end
  hs.fs.link(lazygitConfigDir .. "theme." .. theme .. ".yml", lazygitTheme, true)

  -- set kitty theme
  local kittyColorsDir = configDir .. "/kitty/colors/"
  local kittyTheme = kittyColorsDir .. "solarized.conf"
  local symlinkAttrs = hs.fs.symlinkAttributes(kittyTheme)
  if symlinkAttrs then
    os.remove(kittyTheme)
  end
  hs.fs.link(kittyColorsDir .. "solarized." .. theme .. ".conf", kittyTheme, true)

  for file in hs.fs.dir(runtimeDir) do
    if string.match(file, "^kitty%-%d+$") then
      hs.task
        .new(
          "/opt/homebrew/bin/kitty",
          nil,
          { "@", "--to", "unix:" .. runtimeDir .. "/" .. file, "set-colors", "--all", "--configured", kittyTheme }
        )
        :start()
    elseif string.match(file, "^nvim%.%d+%.%d+") then
      hs.task
        .new(
          "/opt/homebrew/bin/nvim",
          nil,
          { "--server", runtimeDir .. "/" .. file, "--remote-expr", "nvim_set_option('background', '" .. theme .. "')" }
        )
        :start()
    end
  end
end

module.start = function()
  module.watcher = hs.watchable.watch("status.theme", function(_, _, _, _, theme)
    log.d("Theme changed to " .. theme)
    module.applyTheme(theme)
  end)
end

module.stop = function()
  module.watcher:release()
end

return module
