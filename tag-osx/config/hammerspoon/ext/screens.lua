local config = require("config")

local module = {}

-- grabs screen with active window, unless it's Finder's desktop
-- then we use mouse position
module.activeScreen = function()
  local activeWindow = hs.window.focusedWindow()

  if activeWindow and activeWindow:role() ~= "AXScrollArea" then
    return activeWindow:screen()
  else
    return hs.mouse.getCurrentScreen()
  end
end

-- focus screen quitely - with mouse in corner
module.quietFocusScreen = function(screen)
  screen = screen or hs.mouse.getCurrentScreen()

  local frame = screen:frame()
  local mousePosition = hs.mouse.absolutePosition()

  -- if mouse is already on the given screen we can safely return
  if hs.geometry(mousePosition):inside(frame) then
    return false
  end

  -- "hide" cursor in the lower right side of screen
  -- it's invisible while we are changing spaces
  local newMousePosition = {
    x = frame.x + frame.w - 1,
    y = frame.y + frame.h - 1,
  }

  hs.mouse.absolutePosition(newMousePosition)
  hs.timer.usleep(1000)
end

-- focus screen centering mouse
module.focusScreen = function(screen)
  screen = screen or hs.mouse.getCurrentScreen()

  local frame = screen:fullFrame()

  local mousePosition = {
    x = frame.x + frame.w / 2,
    y = frame.y + frame.h / 2,
  }

  -- click center of the screen to bring focus to desktop
  hs.eventtap.leftClick(mousePosition)
end

-- consistent screen naming considering orientation and multiple screens
module.normalizedScreenName = function(screen)
  local name = screen:name():match("^(.*) %(%d%)$") or screen:name()
  local mode = screen:currentMode()
  if mode.h > mode.w then
    name = name .. "-V"
  end
  return name
end

-- find the screen with the correct orientation
module.findScreen = function(screenName)
  local baseScreenName, vertical = screenName:match("^(.*)(%-V)$")
  local matchingScreens = table.pack(hs.screen.find(baseScreenName or screenName))
  return hs.fnutils.find(matchingScreens, function(s)
    if type(s) ~= "userdata" then
      return false
    end
    local mode = s:currentMode()
    return (vertical and mode.h > mode.w) or (not vertical and mode.h <= mode.w)
  end)
end

-- consistently step trough screen based on order in config.wm.displayOrder
module.stepScreen = function(currentScreen, dir)
  local currentScreenName = module.normalizedScreenName(currentScreen)
  local index = hs.fnutils.indexOf(config.wm.displayOrder, currentScreenName)

  if index == nil then
    return false
  end

  local screens = {}
  local screenCount = 0
  hs.fnutils.each(hs.screen.allScreens(), function(s)
    screens[module.normalizedScreenName(s)] = s
    screenCount = screenCount + 1
  end)
  -- cycling less than 3 screens is always consistent
  if screenCount < 3 then
    return false
  end

  while true do
    index = index + dir
    if index > #config.wm.displayOrder then
      index = 1
    end
    if index <= 0 then
      index = #config.wm.displayOrder
    end

    local screenName = config.wm.displayOrder[index]
    -- circled around to current screen, time to give up
    if screenName == currentScreenName then
      return false
    end

    local screen = screens[screenName]
    if screen then
      return screen
    end
  end
end

module.nextScreen = function(screen)
  return module.stepScreen(screen, 1) or screen:next()
end

module.prevScreen = function(screen)
  return module.stepScreen(screen, -1) or screen:previous()
end

return module
