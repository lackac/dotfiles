local system = require("ext.system")

local cache = {}
local module = {
  useFzf = true,
  cache = cache,
}

local log

local commands = {
  ["Hammerspoon Console"] = {
    image = "NSApplicationIcon",
    action = system.toggleConsole,
  },
  ["Toggle Wifi"] = {
    image = "NSNetwork",
    action = system.toggleWiFi,
  },
  ["Show Trash"] = {
    image = "NSTrashFull",
    action = system.showTrash,
  },
  ["Empty Trash"] = {
    image = "NSTrashEmpty",
    action = system.emptyTrash,
  },
  ["Toggle OS Theme"] = {
    image = "NSPreferencesGeneral",
    action = system.toggleTheme,
  },
  ["Start Screensaver"] = {
    image = "NSSlideshowTemplate",
    action = hs.caffeinate.startScreensaver,
  },
  ["Lock Screen"] = {
    image = "NSLockLockedTemplate",
    action = hs.caffeinate.lockScreen,
  },
  ["Logout"] = {
    image = "NSUserGuest",
    action = hs.caffeinate.logOut,
  },
  ["Sleep"] = {
    image = "NSStatusNone",
    action = hs.caffeinate.systemSleep,
  },
  ["Sleep Displays"] = {
    image = "NSStatusPartiallyAvailable",
    action = hs.caffeinate.systemSleep,
  },
  ["Reboot"] = {
    image = "NSTouchBarRefreshTemplate",
    action = hs.caffeinate.restartSystem,
  },
  ["Shutdown"] = {
    image = "NSStatusUnavailable",
    action = hs.caffeinate.shutdownSystem,
  },
}

local function buildChoices()
  cache.choices = {}

  for text, command in pairs(commands) do
    table.insert(cache.choices, {
      text = text,
      id = command.id or module.requireName .. ":" .. text,
      source = module.requireName,
      image = type(command.image) == "string" and hs.image.imageFromName(command.image) or command.image,
    })
  end
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  return cache.choices
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice then
    local command = commands[choice.text]
    if command then
      if type(command.action) == "function" then
        command.action()
      else
        log.wf("couldn't execute action (type: %s) for choice '%s'", type(command.action), choice.text)
      end
    else
      log.wf("couldn't find command '%s'", choice.text)
    end
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "verbose")

  buildChoices()
end

module.stop = function() end

return module
