local spaces = require("hs.spaces")
local activeScreen = require("ext.screens").activeScreen

local cache = {}
local module = { cache = cache }

module.spaceInDirection = function(direction, screen)
  screen = screen or activeScreen()

  local screenSpaces = spaces.spacesForScreen(screen) or {}
  local activeIdx = hs.fnutils.indexOf(screenSpaces, spaces.activeSpaceOnScreen(screen)) or 1
  local targetIdx = direction == "west" and activeIdx - 1 or activeIdx + 1

  return screenSpaces[targetIdx]
end

-- spaceModifier has to be a number!
module.sendToSpace = function(win, spaceModifier)
  local clickPoint = win:zoomButtonRect()
  local sleepTime = 1000

  -- check if all conditions are ok to move the window
  local shouldMoveWindow = hs.fnutils.every({
    clickPoint ~= nil,
    not cache.movingWindowToSpace,
  }, function(test)
    return test
  end)

  if not shouldMoveWindow then
    return
  end

  cache.movingWindowToSpace = true

  clickPoint.x = clickPoint.x + clickPoint.w + 5
  clickPoint.y = clickPoint.y + clickPoint.h / 2

  -- fix for Chrome UI
  if win:application():title() == "Google Chrome" then
    clickPoint.y = clickPoint.y - clickPoint.h
  end

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()
  hs.timer.usleep(sleepTime)

  hs.eventtap.keyStroke({ "ctrl" }, spaceModifier)

  hs.timer.usleep(sleepTime)
  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()

  -- reset cache
  cache.movingWindowToSpace = false
end

return module
