-- global stuff
require("console")
require("overrides")

local bindings = require("bindings")
local modules = {
  bindings,
  require("urls"),
  require("mod.app_logger"),
  require("mod.theme"),
  require("mod.autoborder"),
  require("mod.watchables"),
}

bindings.enabled = {
  "hyper",
  "block-hide",
  "brightness",
  "ctrl-esc",
  "focus",
  "global",
  --"notes",
  "viscosity",
}

local tilingMethod = require("config.wm").tilingMethod

if tilingMethod == "autogrid" then
  table.insert(bindings.enabled, "grid")
  local autogrid = require("mod.autogrid")
  table.insert(modules, autogrid)
else
  table.insert(bindings.enabled, tilingMethod)
end

-- start/stop modules
hs.fnutils.each(modules, function(module)
  if module then
    module.start()
  end
end)

---@diagnostic disable-next-line: duplicate-set-field
hs.shutdownCallback = function()
  hs.fnutils.each(modules, function(module)
    if module then
      module.stop()
    end
  end)
end

-- notify when ready
hs.notify.new({ title = "Hammerspoon", subTitle = "Ready" }):send()
