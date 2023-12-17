local capitalize = require("ext.utils").capitalize
local highlightWindow = require("ext.drawing").highlightWindow
local wm = require("mod.wm")
local config = require("config")

local module = {}
local hhtwm = wm.cache.hhtwm

local move = function(dir)
  local win = hs.window.frontmostWindow()

  if hhtwm.isTiled(win) then
    hhtwm.swapInDirection(win, dir)
  else
    local directions = {
      west = "left",
      south = "down",
      north = "up",
      east = "right",
    }

    hs.grid["pushWindow" .. capitalize(directions[dir])](win)
  end

  highlightWindow()
end

local throw = function(dir)
  local win = hs.window.frontmostWindow()

  if hhtwm.isTiled(win) then
    hhtwm.throwToScreenUsingSpaces(win, dir)
  else
    hs.grid["pushWindow" .. capitalize(dir) .. "Screen"](win)
  end

  highlightWindow()
end

local resize = function(resize)
  local win = hs.window.frontmostWindow()

  if hhtwm.isTiled(win) then
    hhtwm.resizeLayout(resize)
  else
    hs.grid["resizeWindow" .. capitalize(resize)](win)

    highlightWindow()
  end
end

module.start = function()
  wm.start()

  local bind = function(key, fn)
    hs.hotkey.bind({ "ctrl", "shift" }, key, fn, nil, fn)
  end

  -- move window
  hs.fnutils.each({
    { keys = { "h", "4", "left" }, dir = "west" },
    { keys = { "j", "5", "down" }, dir = "south" },
    { keys = { "k", "8", "up" }, dir = "north" },
    { keys = { "l", "6", "right" }, dir = "east" },
  }, function(obj)
    for _, key in ipairs(obj.keys) do
      bind(key, function()
        move(obj.dir)
      end)
    end
  end)

  -- throw between screens
  hs.fnutils.each({
    { key = "]", dir = "next" },
    { key = "[", dir = "prev" },
  }, function(obj)
    bind(obj.key, function()
      throw(obj.dir)
    end)
  end)

  -- resize (floating only)
  hs.fnutils.each({
    { key = ",", dir = "thinner" },
    { key = ".", dir = "wider" },
    { key = "-", dir = "shorter" },
    { key = "=", dir = "taller" },
  }, function(obj)
    bind(obj.key, function()
      resize(obj.dir)
    end)
  end)

  -- toggle [f]loat
  bind("f", function()
    local win = hs.window.frontmostWindow()

    if not win then
      return
    end

    hhtwm.toggleFloat(win)

    if hhtwm.isFloating(win) then
      hs.grid.center(win)
    end

    highlightWindow()
  end)

  -- [r]eset
  bind("r", hhtwm.reset)

  -- re[t]ile
  bind("t", hhtwm.tile)

  -- [e]qualize
  bind("e", hhtwm.equalizeLayout)

  -- use [g]olden ratio
  bind("g", hhtwm.goldenLayout)

  -- cycle windows on space
  bind("y", hhtwm.cycleWindowsOnSpace)

  -- [l]ayout
  hyper.multiBind("l", wm.cycleLayout)

  -- [c]enter window
  bind("c", function()
    local win = hs.window.frontmostWindow()

    if hhtwm.isTiled(win) then
      hhtwm.toggleFloat(win)
    end

    -- win:centerOnScreen()
    hs.grid.center(win)
    highlightWindow()
  end)

  -- toggle [z]oom window
  bind("z", function()
    local win = hs.window.frontmostWindow()

    if hhtwm.isTiled(win) then
      hhtwm.toggleFloat(win)
      hs.grid.maximizeWindow(win)
    else
      hhtwm.toggleFloat(win)
    end

    highlightWindow()
  end)

  -- apply managed layouts
  for n = 0, 9 do
    local idx = tostring(n)

    hyper.multiBind(idx, function()
      local index = n == 0 and 10 or n
      local layout = config.wm.managedLayouts[index]

      if layout then
        hhtwm.applyManagedLayout(layout)
      end
    end)
  end
end

module.stop = function()
  wm.stop()
end

return module
