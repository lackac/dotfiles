local status = hs.watchable.new("status")
local log = hs.logger.new("watchables", "debug")
local isDarkModeEnabled = require("ext.system").isDarkModeEnabled
local debounce = require("ext.utils").debounce

local cache = { status = status }
local module = { cache = cache }

local updateBattery = function()
  local burnRate = hs.battery.designCapacity() / math.abs(hs.battery.amperage())

  status.battery = {
    isCharging = hs.battery.isCharging(),
    isCharged = hs.battery.isCharged(),
    percentage = hs.battery.percentage(),
    powerSource = hs.battery.powerSource(),
    amperage = hs.battery.amperage(),
    wattage = hs.battery.watts(),
    timeRemaining = hs.battery.timeRemaining(),
    timeToFullCharge = hs.battery.timeToFullCharge(),
    burnRate = burnRate,
  }
end

local updateScreen = function()
  status.connectedScreens = #hs.screen.allScreens()
  status.connectedScreenIds = hs.fnutils.map(hs.screen.allScreens(), function(screen)
    return screen:id()
  end)
  status.connectedScreenNames = hs.fnutils.map(hs.screen.allScreens(), function(screen)
    return screen:name()
  end)
  status.isLaptopScreenConnected = hs.screen.findByName("Built-in Retina Display") ~= nil

  log.d("updated screens:", hs.inspect(status.connectedScreenNames))
end

local updateWiFi = function()
  status.currentNetwork = hs.wifi.currentNetwork()

  local location = nil

  for l, n in pairs(config.network) do
    if n == status.currentNetwork then
      location = l
      break
    end
  end

  status.location = location

  log.d("updated wifi:", status.currentNetwork)
end

local updateSleep = function(event)
  status.sleepEvent = event

  log.d("updated sleep:", status.sleepEvent)
end

local updateUSB = function()
  status.isErgodoxAttached = hs.fnutils.find(hs.usb.attachedDevices(), function(device)
    return device.productName == "ErgoDox EZ"
  end) ~= nil

  log.d("updated ergodox:", status.isErgodoxAttached)
end

local updateTheme = function()
  status.theme = isDarkModeEnabled() and "dark" or "light"

  log.d("updated theme:", status.theme)
end

module.start = function()
  -- start watchers
  cache.watchers = {
    screen = hs.screen.watcher.new(updateScreen),
    sleep = hs.caffeinate.watcher.new(updateSleep),
    wifi = hs.wifi.watcher.new(updateWiFi),
    battery = hs.battery.watcher.new(updateBattery),
    theme = hs.distributednotifications.new(updateTheme, "AppleInterfaceThemeChangedNotification"),
    usb = hs.usb.watcher.new(debounce(updateUSB, 3)),
  }

  hs.fnutils.each(cache.watchers, function(watcher)
    watcher:start()
  end)

  -- setup on state start
  updateScreen() -- this is required for automatic main display setup and hhtwm
  updateSleep() -- this is required for autohome and automount
  updateWiFi() -- this is required for authome, automount, and wifi notification
  updateBattery()
  updateTheme()
  updateUSB()
end

module.stop = function()
  hs.fnutils.each(cache.watchers, function(watcher)
    watcher:stop()
  end)
end

return module
