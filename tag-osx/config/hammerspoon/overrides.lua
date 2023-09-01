---@diagnostic disable: duplicate-set-field

local nextScreen = require("ext.screens").nextScreen
local prevScreen = require("ext.screens").prevScreen

-- ensure IPC is there
hs.ipc.cliInstall()

-- https://developer.apple.com/documentation/applicationservices/1459345-axuielementsetmessagingtimeout
hs.window.timeout(0.5)

-- lower logging level for hotkeys
require("hs.hotkey").setLogLevel("warning")

-- no animations
hs.window.animationDuration = 0.0

-- hints
hs.hints.fontName = "Helvetica-Bold"
hs.hints.fontSize = 22
hs.hints.iconAlpha = 1.0
hs.hints.showTitleThresh = 0
-- the following two are kind of mutually exclusive
-- hs.hints.hintChars = { "A", "S", "D", "F", "J", "K", "L", "Q", "W", "E", "R", "Z", "X", "C" }
hs.hints.style = "vimperator"

-- detects if window can be resized
-- this is not ideal, but works
local isResizable = function(win)
  return hs.axuielement.windowElement(win):isAttributeSettable("AXSize")
end

-- local gridMargin = (hhtwm and hhtwm.margin) or 12
local gridMargin = 12

hs.grid.setGrid("18x32") -- default

-- ~ 14 : 9 (MacBook Pro 16-inch, 2023)
hs.grid.setGrid("24x16", "1728x1117") -- cell: 72 x ~70

-- 16 : 9
hs.grid.setGrid("32x18", "1920x1080") -- cell: 60 x 60
hs.grid.setGrid("32x18", "2560x1440") -- cell: 80 x 80
hs.grid.setGrid("32x18", "3200x1800") -- cell: 100 x 100

-- 16 : 10
hs.grid.setGrid("24x15", "1680x1050") -- cell: 70 x 70
hs.grid.setGrid("24x15", "1440x900") -- cell: 60 x 60

-- 16 : 18 (LG DualUp)
hs.grid.setGrid("32x36", "2560x2880") -- cell: 80 x 80
hs.grid.setGrid("32x36", "2048x2304") -- cell: 64 x 64

hs.grid.setMargins({ gridMargin, gridMargin })

hs.grid.getMargins = function()
  return { gridMargin, gridMargin }
end

-- push to next screen without resizing
hs.grid.pushWindowNextScreen = function(win)
  local noResize = true
  local ensureInScreenBounds = true

  win:moveToScreen(nextScreen(win:screen()), noResize, ensureInScreenBounds)
  hs.grid.snap(win)
end

-- push to prev screen without resizing
hs.grid.pushWindowPrevScreen = function(win)
  local noResize = true
  local ensureInScreenBounds = true

  win:moveToScreen(prevScreen(win:screen()), noResize, ensureInScreenBounds)
  hs.grid.snap(win)
end

hs.grid.center = function(win)
  local cell = hs.grid.get(win)
  local screen = win:screen()
  local screenGrid = hs.grid.getGrid(screen)

  cell.x = math.floor(screenGrid.w / 2 - cell.w / 2)
  cell.y = math.floor(screenGrid.h / 2 - cell.h / 2)

  hs.grid.set(win, cell, screen)
end

hs.grid.set = function(win, cell, screen)
  local margins = { w = gridMargin, h = gridMargin }
  local winFrame = win:frame()

  screen = hs.screen.find(screen)
  if not screen then
    screen = win:screen()
  end
  cell = hs.geometry.new(cell)

  -- local screenRect = screen:fullFrame()
  local screenRect = screen:frame()

  -- if hhtwm then
  --   local screenMarginFromTiling = hhtwm.screenMargin.top - hhtwm.margin / 2
  --   screenRect.y = screenRect.y + screenMarginFromTiling
  --   screenRect.h = screenRect.h - screenMarginFromTiling
  -- end

  local screenGrid = hs.grid.getGrid(screen)

  local cellW = screenRect.w / screenGrid.w
  local cellH = screenRect.h / screenGrid.h

  local frame = {
    x = cell.x * cellW + screenRect.x + margins.w,
    y = cell.y * cellH + screenRect.y + margins.h,
    w = cell.w * cellW - (margins.w * 2),
    h = cell.h * cellH - (margins.h * 2),
  }

  local frameMarginX = 0
  local isWinResizable = isResizable(win)

  if not isWinResizable then
    local widthDiv = math.floor(winFrame.w / cellW)

    -- we always want window to take up divisible-by-two cell number
    if widthDiv % 2 == 1 then
      widthDiv = widthDiv + 1
    end

    local frameWidth = widthDiv * cellW
    frameMarginX = (frameWidth - winFrame.w) / 2 - margins.w / 2
    frame.w = winFrame.w
  end

  -- calculate proper margins
  -- this fixes doubled margins betweeen windows

  if cell.h < screenGrid.h and cell.h % 1 == 0 then
    if cell.y ~= 0 then
      frame.h = frame.h + margins.h / 2
      frame.y = frame.y - margins.h / 2
    end

    if cell.y + cell.h ~= screenGrid.h then
      frame.h = frame.h + margins.h / 2
    end
  end

  if cell.w < screenGrid.w and cell.w % 1 == 0 then
    if cell.x ~= 0 then
      if isWinResizable then
        frame.w = frame.w + margins.w / 2
      end
      frame.x = frame.x - margins.w / 2
    end

    if cell.x + cell.w ~= screenGrid.w then
      if isWinResizable then
        frame.w = frame.w + margins.w / 2
      end
    end
  end

  -- snap to edges
  -- or add margins if exist
  local maxMargin = gridMargin * 2

  if cell.x ~= 0 and frame.x - screenRect.x + frame.w > screenRect.w - maxMargin then
    frame.x = screenRect.x + screenRect.w - margins.w - frame.w
  elseif cell.x ~= 0 then
    frame.x = frame.x + frameMarginX
  end

  if cell.y ~= 0 and (frame.y - screenRect.y + frame.h > screenRect.h - maxMargin) then
    frame.y = screenRect.y + screenRect.h - margins.h - frame.h
  end

  -- don't set frame if nothing has changed!
  -- fixes issues with autogrid and infinite updates
  if not winFrame:equals(frame) then
    win:setFrame(frame)
  end

  return hs.grid
end
