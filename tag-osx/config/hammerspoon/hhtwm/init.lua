-- hhtwm - hackable hammerspoon tiling wm

local screens = require("ext.screens")

local createLayouts = require("hhtwm.layouts")

local log = hs.logger.new("hhtwm", "debug")

local cache = { spaces = {}, layouts = {}, floating = {}, displayLayouts = {}, options = {}, layoutOptions = {} }
local module = { cache = cache, log = log }

local layouts = createLayouts(module)

local defaultOptions = {
  margin = 0,
  screenMargin = { top = 0, bottom = 0, right = 0, left = 0 },
  filters = {},
  swapBetweenScreens = false,
  onlyFrontmost = true,
  strictAngle = true,
}

local defaultLayoutOptions = function(golden)
  return {
    mainPaneRatio = golden and 0.618 or 0.5,
  }
end

local calcResizeStep = function(_)
  return 0.1
end

local ensureSpaceCache = function(spaceId)
  if spaceId and not cache.spaces[spaceId] then
    cache.spaces[spaceId] = {}
  end
end

local getSpaceId = function(win)
  local spaceId

  win = win or hs.window.frontmostWindow()

  if win ~= nil then
    local spaces = hs.spaces.windowSpaces(win)
    if spaces ~= nil and #spaces > 0 then
      spaceId = spaces[1]
    end
  end

  return spaceId or hs.spaces.activeSpaceOnScreen()
end

local getSpaceIds = function()
  local spacesLayout = hs.spaces.allSpaces()
  local spaceIds = {}

  for _, spaces in pairs(spacesLayout) do
    for _, spaceId in ipairs(spaces) do
      if hs.spaces.spaceType(spaceId) == "user" then
        table.insert(spaceIds, spaceId)
      end
    end
  end

  return spaceIds
end

local getScreenBySpaceId = function(spaceId)
  return hs.screen.findByID(hs.spaces.spaceDisplay(spaceId))
end

module.setDisplayLayouts = function(newLayouts)
  if type(newLayouts) == "table" then
    cache.displayLayouts = layouts
  else
    log.ef("Wrong type of argument given to %s: %s", debug.getinfo(1, "n").name, hs.inspect(layouts))
  end
end

module.setCalcResizeStep = function(calcFun)
  if type(calcFun) == "function" then
    calcResizeStep = calcFun
  else
    log.ef("Wrong type of argument given to %s: %s", debug.getinfo(1, "n").name, hs.inspect(calcFun))
  end
end

module.option = function(key)
  local value = cache.options[key]
  if value ~= nil then
    return value
  else
    return defaultOptions[key]
  end
end

module.setOptions = function(options)
  for k, v in pairs(options) do
    cache.options[k] = v
  end

  log.d("updating hhtwm options", options)
  hs.settings.set("hhtwm.options", cache.options)
end

module.findTiledWindow = function(win)
  if not win then
    return nil, nil, nil
  end

  for spaceId, spaceWindows in pairs(cache.spaces) do
    for winIndex, window in pairs(spaceWindows) do
      if window:id() == win:id() then
        return window, spaceId, winIndex
      end
    end
  end
end

module.getLayouts = function()
  local layoutNames = {}

  for key in pairs(layouts) do
    table.insert(layoutNames, key)
  end

  return layoutNames
end

module.setLayout = function(layout, spaceId)
  spaceId = spaceId or getSpaceId()
  if not spaceId then
    return
  end

  cache.layouts[spaceId] = layout

  -- remove all floating windows that are on this space,
  -- so retiling will put them back in the layout
  -- this allows us to switch back from floating layout and get windows back to layout
  cache.floating = hs.fnutils.filter(cache.floating, function(win)
    return hs.spaces.windowSpaces(win)[1] ~= spaceId
  end)

  module.tile()
end

module.getLayout = function(spaceId)
  spaceId = spaceId or getSpaceId()

  local screenUUID = hs.spaces.spaceDisplay(spaceId)
  local screen = hs.screen.findByID(screenUUID)

  return cache.layouts[spaceId]
    or (screen and cache.displayLayouts and cache.displayLayouts[screen:id()])
    or (screen and cache.displayLayouts and cache.displayLayouts[screen:name()])
    or "monocle"
end

module.resetLayouts = function()
  for key in pairs(cache.layouts) do
    cache.layouts[key] = nil
    cache.layouts[key] = module.getLayout(key)
  end
end

module.resizeLayout = function(resizeOpt)
  local spaceId = getSpaceId()
  if not spaceId then
    return
  end

  if not cache.layoutOptions[spaceId] then
    cache.layoutOptions[spaceId] = defaultLayoutOptions()
  end

  local screen = getScreenBySpaceId(spaceId)
  local step = calcResizeStep(screen)
  local ratio = cache.layoutOptions[spaceId].mainPaneRatio

  if not resizeOpt then
    ratio = 0.5
  elseif resizeOpt == "thinner" then
    ratio = math.max(ratio - step, 0)
  elseif resizeOpt == "wider" then
    ratio = math.min(ratio + step, 1)
  end

  cache.layoutOptions[spaceId].mainPaneRatio = ratio
  module.tile()
end

module.equalizeLayout = function(golden)
  local spaceId = getSpaceId()
  if not spaceId then
    return
  end

  if cache.layoutOptions[spaceId] then
    cache.layoutOptions[spaceId] = defaultLayoutOptions(golden)

    module.tile()
  end
end

module.goldenLayout = function()
  module.equalizeLayout(true)
end

module.swapInDirection = function(win, direction)
  win = win or hs.window.frontmostWindow()

  if module.isFloating(win) then
    return
  end

  local swapBetweenScreens = module.option("swapBetweenScreens")

  local winCmd = "windowsTo" .. direction:gsub("^%l", string.upper)
  local windowsInDirection =
    cache.filter[winCmd](cache.filter, win, module.option("onlyFrontmost"), module.option("strictAngle"))

  local targets = hs.fnutils.filter(windowsInDirection, function(testWin)
    return testWin:isStandard()
      and module.isTiled(testWin)
      and (swapBetweenScreens or testWin:screen():id() == win:screen():id())
  end)

  if #targets == 0 then
    return
  end

  -- prefer target on same screen
  local target = hs.fnutils.find(targets, function(testWin)
    return testWin:screen():id() == win:screen():id()
  end)
  target = target or targets[1]

  local _, targetSpaceId, targetIdx = module.findTiledWindow(target)
  local _, winSpaceId, winIdx = module.findTiledWindow(win)

  if
    hs.fnutils.some({
      targetSpaceId,
      targetIdx,
      winSpaceId,
      winIdx,
    }, function(_)
      return _ == nil
    end)
  then
    log.e("swapInDirection error", hs.inspect({ targetSpaceId, targetIdx, winSpaceId, winIdx }))
    return
  end
  ---@cast targetSpaceId -nil
  ---@cast targetIdx -nil
  ---@cast winSpaceId -nil
  ---@cast winIdx -nil

  local targetScreen = target:screen()
  local winScreen = win:screen()

  if winScreen:id() ~= targetScreen:id() then
    win:moveToScreen(targetScreen)
    target:moveToScreen(winScreen)
  end

  ensureSpaceCache(winSpaceId)
  ensureSpaceCache(targetSpaceId)

  cache.spaces[winSpaceId][winIdx] = target
  cache.spaces[targetSpaceId][targetIdx] = win

  module.tile()
end

module.cycleWindowsOnSpace = function(spaceId)
  spaceId = spaceId or hs.spaces.activeSpaceOnScreen()

  local spaceCache = cache.spaces[spaceId]

  if spaceCache and #spaceCache > 1 then
    table.insert(spaceCache, 1, spaceCache[#spaceCache])
    table.remove(spaceCache)
    module.tile()
    spaceCache[1]:focus()
  end
end

module.throwToScreen = function(win, direction, usingSpaces)
  win = win or hs.window.frontmostWindow()

  if module.isFloating(win) then
    return
  end

  local directions = {
    next = "nextScreen",
    prev = "prevScreen",
  }

  if not directions[direction] then
    log.e("can't throw in direction:", direction)
    return
  end

  local screen = win:screen()
  local screenInDirection = screens[directions[direction]](screen)

  if not screenInDirection then
    return
  end

  local _, winSpaceId, winIdx = module.findTiledWindow(win)

  if hs.fnutils.some({ winSpaceId, winIdx }, function(_)
    return _ == nil
  end) then
    log.e("throwToScreen error", hs.inspect({ winSpaceId, winIdx }))
    return
  end
  ---@cast winSpaceId -nil
  ---@cast winIdx -nil

  -- remove from tiling so we re-tile that window after it was moved
  if cache.spaces[winSpaceId] then
    table.remove(cache.spaces[winSpaceId], winIdx)
  else
    log.e("throwToScreen no cache.spaces for space id:", winSpaceId)
  end

  if usingSpaces then
    local targetSpaceId = hs.spaces.activeSpaces()[screenInDirection:getUUID()]

    local newX = screenInDirection:frame().x
    local newY = screenInDirection:frame().y

    hs.spaces.moveWindowToSpace(win:id(), targetSpaceId)
    win:setTopLeft(newX, newY)
  else
    win:moveToScreen(screenInDirection)
  end

  if hs.window.animationDuration > 0 then
    hs.timer.doAfter(hs.window.animationDuration * 1.2, module.tile)
  else
    module.tile()
  end
end

module.throwToScreenUsingSpaces = function(win, direction)
  module.throwToScreen(win, direction, true)
end

module.throwToSpace = function(win, spaceIdx)
  if not win then
    log.e("throwToSpace tried to throw nil window")
    return false
  end

  local spaceIds = getSpaceIds()
  local spaceId = spaceIds[spaceIdx]

  if not spaceId then
    log.e("throwToSpace tried to move to non-existing space", spaceId, hs.inspect(spaceIds))
    return false
  end

  local targetScreen = getScreenBySpaceId(spaceId)
  local targetScreenFrame = targetScreen:frame()

  if module.isFloating(win) then
    local newX = win:frame().x - win:screen():frame().x + targetScreenFrame.x
    local newY = win:frame().y - win:screen():frame().y + targetScreenFrame.y

    hs.spaces.moveWindowToSpace(win:id(), spaceId)
    win:setTopLeft(newX, newY)

    return true
  end

  local _, winSpaceId, winIdx = module.findTiledWindow(win)

  if hs.fnutils.some({ winSpaceId, winIdx }, function(_)
    return _ == nil
  end) then
    log.e("throwToSpace error", hs.inspect({ winSpaceId, winIdx }))
    return false
  end
  ---@cast winSpaceId -nil
  ---@cast winIdx -nil

  if cache.spaces[winSpaceId] then
    table.remove(cache.spaces[winSpaceId], winIdx)
  else
    log.e("throwToSpace no cache.spaces for space id:", winSpaceId)
  end

  hs.spaces.moveWindowToSpace(win:id(), spaceId)
  win:setTopLeft(targetScreenFrame.x, targetScreenFrame.y)

  module.tile()

  return true
end

module.isTiled = function(win)
  local tiledWindow, _, _ = module.findTiledWindow(win)
  return tiledWindow ~= nil
end

module.isFloating = function(win)
  return not module.isTiled(win)
end

module.toggleFloat = function(win)
  win = win or hs.window.frontmostWindow()

  if not win then
    return
  end

  local foundWin, winSpaceId, winIdx = module.findTiledWindow(win)

  if foundWin then
    if cache.spaces[winSpaceId] then
      table.remove(cache.spaces[winSpaceId], winIdx)
    else
      log.e("window made floating without previous :space()", hs.inspect(foundWin))
    end

    table.insert(cache.floating, win)
  else
    local spaceId = hs.spaces.windowSpaces(win)[1]
    local foundIdx

    for index, floatingWin in pairs(cache.floating) do
      if not foundIdx then
        if floatingWin:id() == win:id() then
          foundIdx = index
        end
      end
    end

    ensureSpaceCache(spaceId)

    table.insert(cache.spaces[spaceId], win)
    if foundIdx then
      table.remove(cache.floating, foundIdx)
    end
  end

  module.tile()
end

local shouldFloat = function(win)
  local isTiled = module.isTiled(win)
  if isTiled then
    return false
  end

  local floatingWindow = hs.fnutils.find(cache.floating, function(floatingWin)
    return floatingWin:id() == win:id()
  end)
  if floatingWindow ~= nil then
    return true
  end

  return not module.detectTile(win)
end

module.applyManagedLayout = function(layout)
  -- reset floating cache to allow a complete retiling at the end
  cache.floating = {}

  local allWindows = cache.filter:getWindows()
  local windowToFocus = hs.window.focusedWindow()

  for screenName, spaces in pairs(layout) do
    local screen = hs.screen.find(screenName)
    log.d("applyManagedLayout -", screenName, hs.inspect(screen))
    if not screen then
      goto nextSpace
    end

    local spaceIds = hs.spaces.spacesForScreen(screen)
    log.d("applyManagedLayout -- spaces: ", hs.inspect(spaceIds))

    if #spaceIds < #spaces then
      log.df("applyManagedLayout -- adding %d more spaces", #spaces - #spaceIds)
      for _ = 1, #spaces - #spaceIds do
        hs.spaces.addSpaceToScreen(screen, false)
      end
      hs.spaces.closeMissionControl()
      spaceIds = hs.spaces.spacesForScreen(screen)
    end

    for spaceIdx, spaceLayout in ipairs(spaces) do
      local spaceId = spaceIds[spaceIdx]
      log.d("applyManagedLayout --- ", spaceId)
      local newTilingCache = {}

      if spaceLayout.layout ~= nil then
        cache.layouts[spaceId] = spaceLayout.layout
      end

      if spaceLayout.layoutOptions ~= nil then
        cache.layoutOptions[spaceId] = spaceLayout.layoutOptions
      end

      for _, windowFilter in ipairs(spaceLayout.windows) do
        local window = hs.fnutils.find(allWindows, function(win)
          if type(windowFilter) == "string" then
            return win:application():name() == windowFilter
          elseif type(windowFilter) == "table" then
            return (windowFilter.app == nil or win:application():name() == windowFilter.app)
              and (windowFilter.title == nil or string.match(win:title(), windowFilter.title))
          end
        end)
        log.d("applyManagedLayout ---- ", hs.inspect(windowFilter), hs.inspect(window))

        if not window then
          goto nextWindow
        end

        if window:isMinimized() or window:isFullscreen() then
          goto nextWindow
        end

        local winSpaces = hs.spaces.windowSpaces(window)

        if not winSpaces or #winSpaces == 0 then
          goto nextWindow
        end

        if windowFilter.focus then
          windowToFocus = window
        end

        local trackedWin, trackedSpaceId, trackedIdx = module.findTiledWindow(window)

        if trackedWin then
          log.d("applyManagedLayout ---- tracked as ", trackedSpaceId, trackedIdx)
          ---@cast trackedIdx -nil
          table.remove(cache.spaces[trackedSpaceId], trackedIdx)
        end

        if spaceId ~= winSpaces[1] then
          log.df("applyManagedLayout ---- moving window from %d to %d", winSpaces[1], spaceId)
          hs.spaces.moveWindowToSpace(window, spaceId)
        end

        table.insert(newTilingCache, window)

        ::nextWindow::
      end

      -- restore remaining windows from tiling cache
      if cache.spaces[spaceId] then
        for _, window in ipairs(cache.spaces[spaceId]) do
          table.insert(newTilingCache, window)
        end
      end

      cache.spaces[spaceId] = newTilingCache
    end

    ::nextSpace::
  end

  hs.timer.doAfter(hs.spaces.MCwaitTime, function()
    module.tile()
    if windowToFocus then
      windowToFocus:focus()
    end
  end)
end

module.tile = function()
  -- ignore tiling if we're doing something with a mouse
  if #hs.mouse.getButtons() ~= 0 then
    return
  end

  local floatingWindows = {}
  local cacheFlags = {}

  local spaceIds = getSpaceIds()
  local activeSpaces = hs.spaces.activeSpaces()
  local allWindows = hs.window.allWindows()

  -- clean up spaces that don't exist anymore to prevent issues when iterating over windows
  for spaceId, tiledWindows in pairs(cache.spaces) do
    if next(tiledWindows) == nil or not hs.fnutils.contains(spaceIds, spaceId) then
      cache.spaces[spaceId] = nil
    end
  end

  hs.fnutils.each(allWindows or {}, function(win)
    -- we don't care about minimized or fullscreen windows
    if win:isMinimized() or win:isFullscreen() then
      return
    end

    local winSpaces = hs.spaces.windowSpaces(win)

    -- we also don't care about special windows that have no spaces
    if not winSpaces or #winSpaces == 0 then
      return
    end

    if shouldFloat(win) then
      table.insert(floatingWindows, win)
    else
      local spaceId = winSpaces[1]
      local spaceCache = cache.spaces[spaceId] or {}
      local spaceFlags = cacheFlags[spaceId] or {}
      local trackedWin, trackedSpaceId, trackedIdx = module.findTiledWindow(win)

      log.v(
        "update cache.spaces",
        hs.inspect({
          win = win,
          spaces = winSpaces,
          spaceId = spaceId,
          trackedWin = trackedWin or "none",
          trackedSpaceId = trackedSpaceId or "none",
          shouldInsert = not trackedWin or trackedSpaceId ~= spaceId,
        })
      )

      if trackedWin then
        ---@cast trackedIdx -nil
        if trackedSpaceId == spaceId then
          spaceFlags[trackedIdx] = true
        else
          log.d("moving window to another space", hs.inspect(trackedWin), trackedSpaceId, spaceId)
          table.insert(spaceCache, win)
          spaceFlags[#spaceCache] = true
        end
      else
        log.d("inserting new window into cache", hs.inspect(win), spaceId)
        table.insert(spaceCache, win)
        spaceFlags[#spaceCache] = true
      end

      cache.spaces[spaceId] = spaceCache
      cacheFlags[spaceId] = spaceFlags
    end
  end)

  -- clean up tiling cache
  hs.fnutils.each(activeSpaces, function(spaceId)
    local spaceWindows = cache.spaces[spaceId] or {}
    local spaceFlags = cacheFlags[spaceId] or {}

    for i = #spaceWindows, 1, -1 do
      local existsOnScreen = spaceFlags[i]
      if not existsOnScreen then
        table.remove(spaceWindows, i)
      end
    end
  end)

  cache.floating = floatingWindows

  -- apply layout window-by-window
  local moveToFloat = {}

  hs.fnutils.each(activeSpaces, function(spaceId)
    local spaceWindows = cache.spaces[spaceId] or {}
    local screen = getScreenBySpaceId(spaceId)
    local layoutName = module.getLayout(spaceId)

    if not layoutName or not layouts[layoutName] then
      log.e("layout doesn't exist: " .. layoutName)
    else
      for index, window in pairs(spaceWindows) do
        local frame = layouts[layoutName](
          window,
          spaceWindows,
          screen,
          index,
          cache.layoutOptions[spaceId] or defaultLayoutOptions()
        )

        -- only set frame if returned,
        -- this allows for layout to decide if window should be floating
        if frame then
          window:setFrame(frame)
        else
          table.insert(moveToFloat, { window, spaceId, index })
        end
      end
    end
  end)

  hs.fnutils.each(moveToFloat, function(triplet)
    local win, spaceId, winIdx = table.unpack(triplet)

    table.remove(cache.spaces[spaceId], winIdx)
    table.insert(cache.floating, win)
  end)
end

module.detectTile = function(win)
  local app = win:application():name()
  local role = win:role()
  local subrole = win:subrole()
  local title = win:title()

  local filters = module.option("filters")

  if filters then
    local foundMatch = hs.fnutils.find(filters, function(obj)
      local appMatches = obj.app == nil or app == nil or string.match(app, obj.app or "")
      local titleMatches = obj.title == nil or title == nil or string.match(title, obj.title or "")
      local roleMatches = obj.role == nil or obj.role == role
      local subroleMatches = obj.subrole == nil or obj.subrole == subrole

      return appMatches and titleMatches and roleMatches and subroleMatches
    end)

    if foundMatch then
      return foundMatch.tile
    end
  end

  local shouldTileDefault = hs.axuielement.windowElement(win):isAttributeSettable("AXSize")
  return shouldTileDefault
end

module.reset = function()
  log.d("resetting cache")
  log.d("cache.spaces", hs.inspect(cache.spaces))
  log.d("cache.layouts", hs.inspect(cache.layouts))
  log.d("cache.floating", hs.inspect(cache.floating))

  cache.spaces = {}
  cache.layouts = {}
  cache.floating = {}

  module.tile()
end

local loadSettings = function()
  local options = hs.settings.get("hhtwm.options")
  local jsonTilingCache = hs.settings.get("hhtwm.tilingCache")
  local jsonFloatingCache = hs.settings.get("hhtwm.floatingCache")

  log.d("reading from hs.settings")
  log.d("hhtwm.options", options)
  log.d("hhtwm.tilingCache", jsonTilingCache)
  log.d("hhtwm.floatingCache", jsonFloatingCache)

  cache.options = options or {}

  if jsonTilingCache then
    local tilingCache = hs.json.decode(jsonTilingCache)
    local spacesIds = getSpaceIds()

    hs.fnutils.each(tilingCache, function(obj)
      if hs.fnutils.contains(spacesIds, obj.spaceId) then
        cache.spaces[obj.spaceId] = {}
        cache.layouts[obj.spaceId] = obj.layout
        cache.layoutOptions[obj.spaceId] = obj.layoutOptions

        hs.fnutils.each(obj.windowIds, function(winId)
          local win = hs.window.get(winId)

          log.d("restoring (spaceId, windowId, window)", obj.spaceId, winId, win)
          if win then
            table.insert(cache.spaces[obj.spaceId], win)
          end
        end)
      end
    end)
  end

  if jsonFloatingCache then
    local floatingCache = hs.json.decode(jsonFloatingCache)

    hs.fnutils.each(floatingCache, function(winId)
      local win = hs.window.find(winId)

      if win then
        table.insert(cache.floating, win)
      end
    end)
  end

  log.d("read from hs.settings")
  log.d("cache.options", hs.inspect(cache.options))
  log.d("cache.spaces", hs.inspect(cache.spaces))
  log.d("cache.floating", hs.inspect(cache.floating))
end

local saveSettings = function()
  local tilingCache = {}
  local floatingCache = hs.fnutils.map(cache.floating, function(win)
    return win:id()
  end)

  for spaceId, spaceWindows in pairs(cache.spaces) do
    if #spaceWindows > 0 then
      local tmp = {}

      for _, window in pairs(spaceWindows) do
        log.d("storing (spaceId, windowId, window)", spaceId, window:id(), window)
        table.insert(tmp, window:id())
      end

      table.insert(tilingCache, {
        spaceId = spaceId,
        layout = module.getLayout(spaceId),
        layoutOptions = cache.layoutOptions[spaceId],
        windowIds = tmp,
      })
    end
  end

  local jsonTilingCache = hs.json.encode(tilingCache)
  local jsonFloatingCache = hs.json.encode(floatingCache)

  log.d("storing to hs.settings")
  log.d("hhtwm.options", hs.inspect(cache.options))
  log.d("hhtwm.tiling", jsonTilingCache)
  log.d("hhtwm.floating", jsonFloatingCache)

  hs.settings.set("hhtwm.options", cache.options)
  hs.settings.set("hhtwm.tilingCache", jsonTilingCache)
  hs.settings.set("hhtwm.floatingCache", jsonFloatingCache)
end

module.start = function()
  -- discover windows on spaces as soon as possible
  -- hs.window.filter.forceRefreshOnSpaceChange = true

  cache.filter = hs.window.filter.new():setDefaultFilter():setOverrideFilter({
    visible = true,
    fullscreen = false,
    allowRoles = { "AXStandardWindow" },
  })
  -- :setSortOrder(hs.window.filter.sortByCreated)

  loadSettings()

  cache.filter:subscribe({ hs.window.filter.windowsChanged }, module.tile)

  cache.screenWatcher = hs.screen.watcher.new(module.tile):start()

  module.tile()
end

module.stop = function()
  saveSettings()
  cache.filter:unsubscribeAll()
  cache.screenWatcher:stop()
end

return module
