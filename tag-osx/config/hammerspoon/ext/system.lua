local activateFrontmost = require("ext.application").activateFrontmost
local nerdFontsIcon = require("ext.images").nerdFontsIcon

local module = {}

-- show notification center
-- NOTE: you can do that from Settings > Keyboard > Mission Control
module.toggleNotificationCenter = function()
  hs.applescript.applescript([[
    tell application "System Events" to tell process "SystemUIServer"
      click menu bar item "Notification Center" of menu bar 2
    end tell
  ]])
end

module.toggleWiFi = function()
  local newStatus = not hs.wifi.interfaceDetails().power

  hs.wifi.setPower(newStatus)

  hs.notify
    .new({
      title = "Wi-Fi",
      subTitle = "Power: " .. (newStatus and "On" or "Off"),
      contentImage = nerdFontsIcon(newStatus and "󰖩" or "󰖪", "brown"),
    })
    :send()
end

module.toggleConsole = function()
  hs.toggleConsole()
  activateFrontmost()
end

module.displaySleep = function()
  hs.task.new("/usr/bin/pmset", nil, { "displaysleepnow" }):start()
end

module.isDarkModeEnabled = function()
  local _, res = hs.osascript.javascript([[
    Application("System Events").appearancePreferences.darkMode()
  ]])

  return res == true -- getting nil here sometimes
end

module.setTheme = function(theme)
  hs.osascript.javascript(string.format(
    [[
    var systemEvents = Application("System Events");

    ObjC.import("stdlib");

    systemEvents.appearancePreferences.darkMode = %s;
  ]],
    theme == "dark"
  ))
end

module.toggleTheme = function()
  local target = module.isDarkModeEnabled() and "light" or "dark"

  module.setTheme(target)

  hs.notify
    .new({
      title = "Theme",
      subTitle = "Switched to: " .. target,
      contentImage = nerdFontsIcon(target == "light" and "󰖙" or "󰖔", "brown"),
    })
    :send()
end

module.showTrash = function()
  hs.osascript.applescript([[tell application "Finder" to open trash]])
  local trashWindows = hs.window.filter.new(false):setAppFilter("Finder", { allowTitles = "Trash" }):getWindows()
  if trashWindows and #trashWindows > 0 then
    trashWindows[1]:focus()
  end
end

module.emptyTrash = function()
  hs.osascript.applescript([[tell application "Finder" to empty trash]])
end

return module
