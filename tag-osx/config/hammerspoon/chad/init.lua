-- Alfred replacement implemented fully in Hammerspoon

local drawBorder = require("ext.drawing").drawBorder
local fzfFilter = require("ext.fzf").filter

local module = {};

(function()
  local source = debug.getinfo(1, "S").source:sub(2)
  local path, dir = source:match("(.*)/(.*)/init%.lua$")
  module.path = path .. "/" .. dir
  module.name = dir
end)()

local log = hs.logger.new(module.name, "debug")

local chooser
local chooserWindowFilter = hs.window.filter.new(false):setAppFilter("Hammerspoon", { allowTitles = "Chooser" })
local defaultPlaceholder = ""
local shownWithKeyword
local modal
local plugins = {}
local keywords = {}

local latestQuery = ""
local history = {}
local historyMaxSize = 100
local cursor
local savedLatestQuery

local pluginLabel = hs.canvas.new({ x = 0, y = 0, w = 100, h = 18 }):appendElements({
  type = "text",
  text = "",
  textSize = 16,
  textColor = hs.drawing.color.x11.dimgray,
  textAlignment = "center",
})

local function updatePluginLabel()
  local text = module.name
  if module.activeKeyword then
    text = text .. " / " .. keywords[module.activeKeyword].name
  end
  pluginLabel[1].text = text
end

local function showPluginLabel()
  module.withChooserWindow(function(_, axWindow)
    updatePluginLabel()
    local frame = axWindow:attributeValue("AXFrame")
    pluginLabel
      :frame({
        x = frame.x,
        y = frame.y + 2,
        w = frame.w,
        h = 18,
      })
      :show()
  end)
end

local function hidePluginLabel()
  if pluginLabel:isShowing() then
    pluginLabel:hide()
    pluginLabel[1].text = ""
  end
end

local preview = hs.canvas.new({ x = 0, y = 0, w = 100, h = 100 }):appendElements(
  { type = "rectangle", roundedRectRadii = { xRadius = 8, yRadius = 8 }, action = "fill", fillColor = { alpha = 0.8 } },
  {
    type = "text",
    text = "",
    textFont = "FiraCode Nerd Font",
    textSize = 16,
    textColor = hs.drawing.color.x11.snow,
    padding = 8,
  }
)

local function showPreview(text)
  module.withChooserWindow(function(_, axWindow)
    preview[2].text = text

    local minFrame = preview:minimumTextSize(2, text)
    local chooserFrame = axWindow:attributeValue("AXFrame")
    preview
      :frame({
        x = chooserFrame.x + chooserFrame.w / 2 - minFrame.w / 2 - 8,
        y = chooserFrame.y + chooserFrame.h + 10,
        w = minFrame.w + 16,
        h = minFrame.h + 16,
      })
      :show()
  end)
end

local function hidePreview()
  if preview:isShowing() then
    preview:hide()
    preview[1].text = ""
  end
end

local function updatePreview()
  local item = chooser:selectedRowContents()
  if item.fullText then
    showPreview(item.fullText)
  else
    hidePreview()
  end
end

local queryDelay = hs.timer.delayed.new(0.2, function()
  module.queryChanged(latestQuery, true)
end)

local function prevQueryOrRow()
  local selectedRow = chooser:selectedRow()
  if selectedRow > 1 then
    chooser:selectedRow(selectedRow - 1)
    updatePreview()
    return
  end

  if not history or not history[1] then
    return
  end

  if cursor == nil then
    cursor = #history
    savedLatestQuery = module.saveQuery()
  else
    cursor = cursor - 1
  end
  if cursor < 1 then
    cursor = 1
  end
  log.vf("cursor at %d/%d (%s)", cursor, #history, hs.inspect(history[cursor]))

  module.restoreQuery(history[cursor])
end

local function nextQueryOrRow()
  if cursor == nil then
    chooser:selectedRow(chooser:selectedRow() + 1)
    updatePreview()
    return
  elseif cursor == #history then
    if savedLatestQuery then
      chooser:selectedRow(chooser:selectedRow() + 1)
      updatePreview()
    else
      cursor = nil
      module.updateQuery()
    end
    return
  else
    cursor = cursor + 1
  end
  log.vf("cursor at %d/%d (%s)", cursor, #history, hs.inspect(history[cursor]))

  module.restoreQuery(history[cursor])
end

local function prevRow()
  local selectedRow = chooser:selectedRow()
  if selectedRow > 1 then
    chooser:selectedRow(selectedRow - 1)
    updatePreview()
  end
end

local function nextRow()
  local selectedRow = chooser:selectedRow()
  chooser:selectedRow(selectedRow + 1)
  updatePreview()
end

local function prevPage()
  local selectedRow = chooser:selectedRow()
  if selectedRow > 1 then
    chooser:selectedRow(math.max(selectedRow - 1, 1))
    updatePreview()
  end
end

local function nextPage()
  local selectedRow = chooser:selectedRow()
  chooser:selectedRow(selectedRow + 10)
  updatePreview()
end

local function bindKeys()
  modal:bind({}, "escape", function()
    if module.activeKeyword and not shownWithKeyword then
      module.deactivateKeyword()
    else
      module.hide()
    end
  end)

  modal:bind({}, "tab", function()
    local cleanedQuery = string.match(latestQuery, "^%s*(%S+)%s*$")
    if cleanedQuery and keywords[cleanedQuery] then
      module.activateKeyword(cleanedQuery)
    end
  end)

  modal:bind({}, "up", prevQueryOrRow, nil, prevQueryOrRow)
  modal:bind({}, "down", nextQueryOrRow, nil, nextQueryOrRow)
  modal:bind({ "ctrl" }, "p", prevRow, nil, prevRow)
  modal:bind({ "ctrl" }, "n", nextRow, nil, nextRow)
  modal:bind({}, "pageup", prevPage, nil, prevPage)
  modal:bind({}, "pagedown", nextPage, nil, nextPage)
end

local function loadPlugin(pluginName)
  local requireName = module.name .. "." .. pluginName
  local ok, plugin = pcall(require, requireName)
  if ok then
    plugin.name = pluginName
    plugin.requireName = requireName
    if type(plugin.start) == "function" then
      plugin.start(module, pluginName)
    end

    plugins[requireName] = plugin
    if plugin.keyword or type(plugin.autoActivate) == "string" then
      local keyword = plugin.keyword or plugin.autoActivate
      if keywords[keyword] then
        log.wf(
          "plugin keyword '%s' aleady reserved for plugin '%s' when loading '%s' which could lead to unexpected behaviour",
          keyword,
          keywords[keyword].requireName,
          requireName
        )
      else
        keywords[keyword] = plugin
      end
    end

    log.d("plugin " .. pluginName .. " loaded")
  else
    log.e("couldn't load plugin " .. pluginName .. "\n" .. plugin)
  end
end

local function loadPlugins()
  plugins = {}

  for pluginFile in hs.fs.dir(module.path) do
    -- skip init.lua and files starting with an underscore
    local pluginName = pluginFile:match("^([^_].*)%.lua$")
    if pluginName and pluginName ~= "init" then
      log.d("loading plugin " .. pluginName)
      loadPlugin(pluginName)
    end
  end
end

local function trimQueryHistory()
  local size = #history
  if size > historyMaxSize then
    local trimmed = {}
    table.move(history, size - historyMaxSize + 1, size, 1, trimmed)
    history = trimmed
  end
end

module.chooserWindow = function()
  return chooserWindowFilter:getWindows()[1]
end

module.withChooserWindow = function(callback)
  local timer = hs.timer.waitUntil(module.chooserWindow, function()
    local window = module.chooserWindow()
    if not window then
      log.w("can't find chooser window")
      return
    end

    local axWindow = hs.axuielement.windowElement(window)
    if not axWindow or not axWindow:isValid() then
      log.w("can't find valid AXWindow for chooser")
      return
    end

    callback(window, axWindow)
  end, 0.1)

  hs.timer.doAfter(1, function()
    if timer:running() then
      log.w("could't find chooser window")
      timer:stop()
    end
  end)
end

module.queryChanged = function(query, timeout)
  if timeout then
    log.v("delayed query: " .. hs.inspect(query))
    cursor = nil
    savedLatestQuery = nil
    chooser:refreshChoicesCallback()
  elseif query == "" then
    -- shortcut when emptying the query to avoid delay
    latestQuery = query
    chooser:refreshChoicesCallback()
  elseif keywords[query] and (keywords[query].autoActivate == true or keywords[query].autoActivate == query) then
    module.activateKeyword(query)
  else
    local potentialKeyword = query:match("^%s*(%S+)%s+$")
    if potentialKeyword and keywords[potentialKeyword] then
      module.activateKeyword(potentialKeyword)
      return
    end

    log.v("query: " .. hs.inspect(query))
    latestQuery = query
    queryDelay:start()
  end
end

module.compileChoices = function()
  local mapOfChoices = {}
  local numberOfPlugins = 0
  local numberOfSources = 0
  local totalChoices = 0
  local useFzf = false
  local fzfOpts = { "-i --delimiter '\t' --with-nth 2.. --read0 --print0" }

  log.v("compiling choices from plugins")
  for requireName, plugin in pairs(plugins) do
    if
      plugin.keyword == module.activeKeyword
      or type(plugin.autoActivate) == "string" and plugin.autoActivate == module.activeKeyword
    then
      numberOfPlugins = numberOfPlugins + 1
      local pluginChoices = plugin.compileChoices(latestQuery)
      useFzf = useFzf or plugin.useFzf
      if plugin.fzfOpts then
        table.insert(fzfOpts, plugin.fzfOpts)
      end
      if #pluginChoices > 0 then
        -- considering this a plain list of choices and adding to our map
        mapOfChoices[requireName] = pluginChoices
        numberOfSources = numberOfSources + 1
        totalChoices = totalChoices + #pluginChoices
      else
        -- must be either empty or a map of tables, this works either way
        for k, v in pairs(pluginChoices) do
          mapOfChoices[k] = v
          numberOfSources = numberOfSources + 1
          totalChoices = totalChoices + #v
        end
      end
    end
    if module.activeKeyword == nil and plugin.tip then
      mapOfChoices["tips"] = mapOfChoices["tips"] or {}
      plugin.tip.id = plugin.tip.id or plugin.requireName
      plugin.tip.keyword = plugin.tip.keyword or plugin.keyword or plugin.autoActivate
      plugin.tip.valid = false
      table.insert(mapOfChoices["tips"], plugin.tip)
    end
  end
  log.vf(
    "compiled %d choices from %d sources of %d plugins, %sgoing to use fzf",
    totalChoices,
    numberOfSources,
    numberOfPlugins,
    useFzf and "" or "not "
  )

  if numberOfSources == 1 and not useFzf then
    -- special case, likely plugin with keyword
    for _, choices in pairs(mapOfChoices) do
      hs.timer.doAfter(0.25, updatePreview)
      return choices
    end
  end

  -- shortcut for loading progress indicators
  if totalChoices == 1 then
    for _, choicesInSource in pairs(mapOfChoices) do
      local choiceId = choicesInSource[1] and choicesInSource[1].id
      if choiceId:match("%-progress$") then
        hs.timer.doAfter(0.25, updatePreview)
        return choicesInSource
      end
    end
  end

  local lookup = {}
  local choices = {}

  -- special case mainly for the calculator
  for key, choicesInSource in pairs(mapOfChoices) do
    if plugins[key] and not plugins[key].useFzf then
      for _, choice in ipairs(choicesInSource) do
        table.insert(choices, choice)
      end
    end
  end

  fzfFilter(latestQuery, function(file)
    for key, choicesInSource in pairs(mapOfChoices) do
      if not plugins[key] or plugins[key].useFzf then
        for _, choice in ipairs(choicesInSource) do
          local fzfChoice = choice.fzfInput or choice.fullText or choice.text
          file:write(choice.id .. "\t" .. fzfChoice .. "\0")
          lookup[choice.id] = choice
        end
      end
    end
  end, function(line)
    local id = line:match("([^\t]*)")
    if id and lookup[id] then
      table.insert(choices, lookup[id])
    end
  end, table.concat(fzfOpts, " "))

  -- trigger preview for first choice
  hs.timer.doAfter(0.25, updatePreview)

  return choices
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))

  if choice then
    if choice.source then
      local plugin = plugins[choice.source]
      if plugin then
        plugin.complete(choice)
      else
        log.ef("can't find plugin source for choice: %s", hs.inspect(choice.source))
      end
    end
  end
end

module.willOpen = function()
  log.v("willOpen")
  local focusedElement = hs.uielement.focusedElement()
  local selectedText = focusedElement and focusedElement:selectedText()
  if selectedText and selectedText ~= "" then
    module.currentSelection = selectedText
  else
    module.currentSelection = nil
  end
end

module.shown = function()
  log.v("shown")
  drawBorder()
  showPluginLabel()
  modal:enter()
end

module.hidden = function()
  log.v("hidden")
  module.saveQuery()
  hidePluginLabel()
  hidePreview()
  drawBorder()
  modal:exit()
end

module.invalid = function(choice)
  log.v("invalid choice: " .. hs.inspect(choice))
  if choice then
    if choice.keyword then
      module.activateKeyword(choice.keyword)
    end
  end
end

module.rightClicked = function(row)
  log.v("right clicked row: " .. hs.inspect(row))
end

module.show = function()
  log.v("showing")
  cursor = nil
  module.updateQuery()
  chooser:show()
end

module.showWithKeyword = function(keyword)
  if keywords[keyword] then
    log.df("activating keyword '%s'", keyword)
    module.updateQuery(nil, keyword)
    if not chooser:isVisible() then
      cursor = nil
      shownWithKeyword = true
      chooser:show()
    end
    updatePluginLabel()
  else
    log.wf("no such keyword '%s'", keyword)
  end
end

module.hide = function()
  log.v("hiding")
  queryDelay:stop()
  shownWithKeyword = nil
  chooser:hide()
end

module.toggle = function()
  if chooser:isVisible() then
    module.hide()
  else
    module.show()
  end
end

module.updateQuery = function(query, keyword)
  module.activeKeyword = keyword
  chooser:placeholderText(keyword and keywords[keyword].placeholder or defaultPlaceholder)
  chooser:query(query)
  latestQuery = query or ""
  chooser:refreshChoicesCallback()
end

module.saveQuery = function()
  if latestQuery == "" then
    return
  end

  -- don't save query if it's the same as the last one
  local lastItem = history[#history]
  if type(lastItem) == "string" and module.activeKeyword == nil and lastItem == latestQuery then
    return true
  end
  if type(lastItem) == "table" and lastItem[1] == module.activeKeyword and lastItem[2] == latestQuery then
    return true
  end

  table.insert(history, module.activeKeyword and { module.activeKeyword, latestQuery } or latestQuery)
  if #history > historyMaxSize * 1.5 then
    trimQueryHistory()
  end
  return true
end

module.restoreQuery = function(query)
  local keyword

  if type(query) == "table" then
    keyword = query[1]
    query = query[2]
  elseif type(query) ~= "string" then
    log.wf("can't restore query %s, wrong type", hs.inspect(query))
    return
  end

  module.updateQuery(query, keyword)
end

module.activateKeyword = function(keyword)
  if keywords[keyword] then
    log.df("activating keyword '%s'", keyword)
    module.updateQuery(nil, keyword)
    updatePluginLabel()
  else
    log.wf("no such keyword '%s'", keyword)
  end
end

module.deactivateKeyword = function()
  if module.activeKeyword then
    log.df("deactivating keyword '%s'", module.activeKeyword)
    module.saveQuery()
    module.updateQuery()
    updatePluginLabel()
  end
end

module.start = function()
  chooser = hs.chooser
    .new(module.complete)
    :choices(module.compileChoices)
    :enableDefaultForQuery(true)
    :showCallback(module.shown)
    :hideCallback(module.hidden)
    :invalidCallback(module.invalid)
    :queryChangedCallback(module.queryChanged)
    :rightClickCallback(module.rightClicked)

  loadPlugins()
  history = hs.settings.get(module.name .. ":queryHistory") or {}

  modal = hs.hotkey.modal.new()
  bindKeys()

  module.chooser = chooser

  hs.chooser.globalCallback = function(whichChooser, event)
    if chooser == whichChooser and event == "willOpen" then
      module.willOpen()
    end
    return hs.chooser._defaultGlobalCallback(whichChooser, event)
  end
end

module.stop = function(reload)
  hs.chooser.globalCallback = hs.chooser._defaultGlobalCallback

  trimQueryHistory()
  hs.settings.set(module.name .. ":queryHistory", history)

  chooser:delete()
  chooser = nil

  for requireName, plugin in pairs(plugins) do
    if type(plugin.stop) == "function" then
      plugin.stop()
    end
    if reload then
      package.loaded[requireName] = nil
    end
  end
  plugins = {}
  keywords = {}

  modal:exit()
  modal:delete()

  module.chooser = nil
end

local function reloadPlugin(pluginName)
  local requireName = module.name .. "." .. pluginName
  local plugin = plugins[requireName]

  if plugin then
    if type(plugin.stop) == "function" then
      plugin.stop()
    end
    package.loaded[requireName] = nil
    plugins[requireName] = nil
    local keyword = plugin.keyword or plugin.autoActivate
    if keyword and keywords[keyword] == plugin then
      keywords[keyword] = nil
    end
    loadPlugin(pluginName)
  else
    log.wf("couldn't find plugin '%s' to reload", pluginName)
  end
end

module.reload = function(plugin)
  if plugin then
    log.f("reloading plugin '%s'", plugin)
    return reloadPlugin(plugin)
  end

  log.f("reloading %s", module.name)
  module.stop(true)
  package.loaded[module.name] = nil
  local newModule = require(module.name)
  newModule:start()
  newModule:toggle()
end

return module
