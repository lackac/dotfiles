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

  hs.task.new(os.getenv("HOME") .. "/bin/theme", nil, { theme }):start()
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
