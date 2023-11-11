local system = require("ext.system")
local nerdFontsIcon = require("ext.images").nerdFontsIcon

local cache = {}
local module = {
  useFzf = true,
  cache = cache,
}

local log

local commands = {
  ["Hammerspoon Console"] = {
    image = "",
    action = system.toggleConsole,
  },
  ["Reload Hammerspoon"] = {
    image = "󰜉",
    action = hs.reload,
  },
  ["Relaunch Hammerspoon"] = {
    image = "󱄌",
    action = hs.relaunch,
  },
  ["Reload Applications Cache"] = {
    image = "󰑓",
    action = function()
      local appsPlugin = require(module.main.name .. ".apps")
      appsPlugin.reloadApplications()
    end,
  },
  ["Toggle Wifi"] = {
    image = "󰖩",
    action = system.toggleWiFi,
  },
  ["Show Trash"] = {
    image = "",
    action = system.showTrash,
  },
  ["Empty Trash"] = {
    image = "󱂨",
    action = system.emptyTrash,
  },
  ["Toggle OS Theme"] = {
    image = "󰔎",
    action = system.toggleTheme,
  },
  ["Start Screensaver"] = {
    image = "󱄄",
    action = hs.caffeinate.startScreensaver,
  },
  ["Lock Screen"] = {
    image = "󰷛",
    action = hs.caffeinate.lockScreen,
  },
  ["Logout"] = {
    image = "󰍃",
    action = hs.caffeinate.logOut,
  },
  ["Sleep"] = {
    image = "󰒲",
    action = hs.caffeinate.systemSleep,
  },
  ["Sleep Displays"] = {
    image = "󰶐",
    action = hs.caffeinate.systemSleep,
  },
  ["Reboot"] = {
    image = "󰜉",
    action = hs.caffeinate.restartSystem,
  },
  ["Shutdown"] = {
    image = "",
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
      image = nerdFontsIcon(command.image, "darkmagenta"),
    })
  end
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  if query ~= "" then
    return cache.choices
  else
    return {}
  end
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
  log = hs.logger.new(module.requireName, "debug")

  buildChoices()
end

module.stop = function() end

return module
