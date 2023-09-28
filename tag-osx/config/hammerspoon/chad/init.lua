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
local defaultPlaceholder = ""
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
  local window = hs.window.filter.new(false):setAppFilter("Hammerspoon", { allowTitles = "Chooser" }):getWindows()[1]
  if not window then
    log.w("can't find chooser window for attaching label")
    return
  end

  local axWindow = hs.axuielement.windowElement(window)
  if not axWindow or not axWindow:isValid() then
    log.w("can't find valid AXWindow for chooser for attaching label")
    return
  end

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
end

local function hidePluginLabel()
  if pluginLabel:isShowing() then
    pluginLabel:hide()
    pluginLabel[1].text = ""
  end
end

local queryDelay = hs.timer.delayed.new(0.2, function()
  module.queryChanged(latestQuery, true)
end)

local function prevQueryRow()
  local selectedRow = chooser:selectedRow()
  if selectedRow > 1 then
    chooser:selectedRow(selectedRow - 1)
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
    return
  elseif cursor == #history then
    if savedLatestQuery then
      chooser:selectedRow(chooser:selectedRow() + 1)
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

local function bindKeys()
  modal:bind({}, "escape", function()
    if module.activeKeyword then
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

  modal:bind({}, "up", prevQueryRow, nil, prevQueryRow)

  modal:bind({}, "down", nextQueryOrRow, nil, nextQueryOrRow)
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

  log.v("compiling choices from plugins")
  for requireName, plugin in pairs(plugins) do
    if
      plugin.keyword == module.activeKeyword
      or type(plugin.autoActivate) == "string" and plugin.autoActivate == module.activeKeyword
    then
      numberOfPlugins = numberOfPlugins + 1
      local pluginChoices = plugin.compileChoices(latestQuery)
      useFzf = useFzf or plugin.useFzf
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
      return choices
    end
  end

  -- shortcut for loading progress indicators
  if totalChoices == 1 then
    for _, choicesInSource in pairs(mapOfChoices) do
      local choiceId = choicesInSource[1] and choicesInSource[1].id
      if choiceId:match("%-progress$") then
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
          file:write(choice.id .. "\t" .. choice.text .. "\n")
          lookup[choice.id] = choice
        end
      end
    end
  end, function(line)
    local id = line:match("([^\t]*)")
    if id and lookup[id] then
      table.insert(choices, lookup[id])
    end
  end)

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
  module.activeKeyword = nil
  chooser:query(nil)
  chooser:show()
end

module.hide = function()
  log.v("hiding")
  queryDelay:stop()
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
end

module.stop = function(reload)
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
