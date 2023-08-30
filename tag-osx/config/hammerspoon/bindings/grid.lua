local highlightWindow = require("ext.drawing").highlightWindow
local spaces = require("hs.spaces")
local window = require("ext.window")

local module = {}

-- apply function to a window with optional params, saving it's position for restore
local doWin = function(fn)
  return function()
    local win = hs.window.frontmostWindow()

    if win and not win:isFullScreen() then
      window.persistPosition(win, "save")
      fn(win)
      highlightWindow(win)
    end
  end
end

local getSpaceIdsTable = function()
  local allSpaces = spaces.allSpaces() or {}
  local spacesIds = {}

  hs.fnutils.each(hs.screen.allScreens(), function(screen)
    local screenUUID = screen:getUUID()

    local userSpaces = hs.fnutils.filter(allSpaces[screenUUID] or {}, function(spaceId)
      return spaces.spaceType(spaceId) == "user"
    end)

    hs.fnutils.concat(spacesIds, userSpaces or {})
  end)

  return spacesIds
end

local throwToSpace = function(win, spaceIdx)
  local spacesIds = getSpaceIdsTable()
  local spaceId = spacesIds[spaceIdx]

  if not spaceId then
    return false
  end

  spaces.moveWindowToSpace(win:id(), spaceId)
end

module.start = function()
  local bind = function(key, fn)
    hs.hotkey.bind({ "ctrl", "shift" }, key, fn, nil, fn)
  end

  hs.fnutils.each({
    { key = "h", fn = hs.grid.pushWindowLeft },
    { key = "j", fn = hs.grid.pushWindowDown },
    { key = "k", fn = hs.grid.pushWindowUp },
    { key = "l", fn = hs.grid.pushWindowRight },

    { key = "[", fn = hs.grid.pushWindowPrevScreen },
    { key = "]", fn = hs.grid.pushWindowNextScreen },

    { key = ";", fn = hs.grid.pushWindowPrevSpace },
    { key = "'", fn = hs.grid.pushWindowNextSpace },

    { key = ",", fn = hs.grid.resizeWindowThinner },
    { key = ".", fn = hs.grid.resizeWindowWider },

    { key = "-", fn = hs.grid.resizeWindowShorter },
    { key = "=", fn = hs.grid.resizeWindowTaller },

    { key = "z", fn = hs.grid.maximizeWindow },
    { key = "c", fn = hs.grid.center },
  }, function(object)
    bind(object.key, doWin(object.fn))
  end)

  bind("u", function()
    window.persistPosition(hs.window.frontmostWindow(), "undo")
  end)
  bind("r", function()
    window.persistPosition(hs.window.frontmostWindow(), "redo")
  end)

  -- throw window to space (and move)
  for n = 0, 9 do
    local idx = tostring(n)

    -- important: use this with onKeyReleased, not onKeyPressed
    hs.hotkey.bind({ "ctrl", "shift" }, idx, nil, function()
      local win = hs.window.focusedWindow()

      if win then
        throwToSpace(win, n == 0 and 10 or n)
      end

      hs.eventtap.keyStroke({ "ctrl" }, idx)
    end)
  end
end

module.stop = function() end

return module
