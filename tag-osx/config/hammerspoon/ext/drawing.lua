local config = require("config")

local cache = { borderDrawings = {}, borderDrawingFadeOuts = {} }
local module = { cache = cache }

-- returns 'graphite' or 'aqua'
local getOSXAppearance = function()
  local _, res = hs.applescript.applescript([[
    tell application "System Events"
      tell appearance preferences
        return appearance as string
      end tell
    end tell
  ]])

  return res
end

-- get appearance on start
cache.osxAppearance = getOSXAppearance()

module.getHighlightWindowColor = function()
  local orange = { red = 254 / 255, green = 129 / 255, blue = 8 / 255, alpha = 1.0 }
  local blue = { red = 50 / 255, green = 138 / 255, blue = 215 / 255, alpha = 1.0 }
  local gray = { red = 143 / 255, green = 143 / 255, blue = 143 / 255, alpha = 1.0 }

  return cache.osxAppearance == "graphite" and gray or orange or blue
end

module.drawBorder = function()
  local focusedWindow = hs.window.focusedWindow()

  if not focusedWindow or focusedWindow:role() ~= "AXWindow" or focusedWindow:isFullscreen() then
    if cache.borderCanvas then
      cache.borderCanvas:hide(0.5)
    end

    return
  end

  local borderStyle = config.window.borderStyle or {}

  local alpha = borderStyle.alpha or 0.6
  local borderWidth = borderStyle.width or 2
  local distance = borderStyle.distance or 6
  local roundRadius = borderStyle.roundRadius or 12

  local frame = focusedWindow:frame()

  if not cache.borderCanvas then
    cache.borderCanvas = hs.canvas
      .new({ x = 0, y = 0, w = 0, h = 0 })
      :level(hs.canvas.windowLevels.overlay)
      :behavior({ hs.canvas.windowBehaviors.transient, hs.canvas.windowBehaviors.moveToActiveSpace })
      :alpha(alpha)
  end

  cache.borderCanvas:frame({
    x = frame.x - distance / 2,
    y = frame.y - distance / 2,
    w = frame.w + distance,
    h = frame.h + distance,
  })

  cache.borderCanvas[1] = {
    type = "rectangle",
    action = "stroke",
    strokeColor = module.getHighlightWindowColor(),
    strokeWidth = borderWidth,
    roundedRectRadii = { xRadius = roundRadius, yRadius = roundRadius },
  }

  cache.borderCanvas:show()
end

module.highlightWindow = function(win)
  if config.window.highlightBorder then
    module.drawBorder()
  end

  if config.window.highlightMouse then
    local focusedWindow = win or hs.window.focusedWindow()
    if not focusedWindow or focusedWindow:role() ~= "AXWindow" then
      return
    end

    local frameCenter = hs.geometry.getcenter(focusedWindow:frame())

    hs.mouse.absolutePosition(frameCenter)
  end
end

return module
