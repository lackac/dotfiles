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

local log = hs.logger.new(module.name, "verbose")

local chooser
local defaultPlaceholder = ""
local modal
local plugins = {}
local activeKeyword
local keywords = {}

local latestQuery
local queryDelay = hs.timer.delayed.new(0.2, function()
  module.queryChanged(latestQuery, true)
end)

local function bindKeys()
  modal:bind({}, "escape", function()
    if activeKeyword then
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
end

local function loadPlugin(pluginName)
  local requireName = module.name .. "." .. pluginName
  local ok, plugin = pcall(require, requireName)
  if ok then
    plugin.requireName = requireName
    if type(plugin.start) == "function" then
      plugin.start(module, pluginName)
    end

    plugins[requireName] = plugin
    if plugin.keyword then
      if keywords[plugin.keyword] then
        log.wf(
          "plugin keyword '%s' aleady reserved for plugin '%s' when loading '%s' which could lead to unexpected behaviour",
          plugin.keyword,
          keywords[plugin.keyword].requireName,
          requireName
        )
      else
        keywords[plugin.keyword] = plugin
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

module.queryChanged = function(query, timeout)
  if timeout then
    log.v("delayed query: " .. hs.inspect(query))
    chooser:refreshChoicesCallback()
  elseif query == "" then
    -- shortcut when emptying the query to avoid delay
    latestQuery = query
    chooser:refreshChoicesCallback()
  elseif keywords[query] and keywords[query].autoActivate then
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
    if plugin.keyword == activeKeyword then
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
    elseif activeKeyword == nil and plugin.keyword and plugin.tip then
      mapOfChoices["tips"] = mapOfChoices["tips"] or {}
      plugin.tip.id = plugin.tip.id or plugin.requireName
      plugin.tip.keyword = plugin.tip.keyword or plugin.keyword
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

  local lookup = {}
  local choices = {}
  fzfFilter(latestQuery, function(file)
    for _, choicesInSource in pairs(mapOfChoices) do
      for _, choice in ipairs(choicesInSource) do
        file:write(choice.id .. "\t" .. choice.text .. "\n")
        lookup[choice.id] = choice
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
  modal:enter()
end

module.hidden = function()
  log.v("hidden")
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
  activeKeyword = nil
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

module.clearQuery = function()
  chooser:placeholderText(activeKeyword and keywords[activeKeyword].placeholder or defaultPlaceholder)
  chooser:query(nil)
  latestQuery = ""
  chooser:refreshChoicesCallback()
end

module.activateKeyword = function(keyword)
  if keywords[keyword] then
    log.df("activating keyword '%s'", keyword)
    activeKeyword = keyword
    module.clearQuery()
  else
    log.wf("no such keyword '%s'", keyword)
  end
end

module.deactivateKeyword = function()
  if activeKeyword then
    log.df("deactivating keyword '%s'", activeKeyword)
    activeKeyword = nil
    module.clearQuery()
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

  modal = hs.hotkey.modal.new()
  bindKeys()

  module.chooser = chooser
end

module.stop = function(reload)
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
    if plugin.keyword and keywords[plugin.keyword] == plugin then
      keywords[plugin.keyword] = nil
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
