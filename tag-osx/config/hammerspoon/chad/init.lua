-- Alfred replacement implemented fully in Hammerspoon

local module = {};

(function()
  local source = debug.getinfo(1, "S").source:sub(2)
  local path, dir = source:match("(.*)/(.*)/init%.lua$")
  module.path = path .. "/" .. dir
  module.name = dir
end)()

local log = hs.logger.new(module.name, "verbose")

local chooser
local plugins = {}
local activeKeyword

local FZF_PATH = "/opt/homebrew/bin/fzf"

local function loadPlugin(pluginName)
  local requireName = module.name .. "." .. pluginName
  local ok, plugin = pcall(require, requireName)
  if ok then
    plugin.requireName = requireName
    if type(plugin.start) == "function" then
      plugin.start(module, pluginName)
    end
    plugins[requireName] = plugin
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

local latestQuery
local queryDelay = hs.timer.delayed.new(0.2, function()
  module.queryChanged(latestQuery, true)
end)

module.queryChanged = function(query, timeout)
  if timeout then
    log.v("delayed query: " .. hs.inspect(query))
    chooser:refreshChoicesCallback()
  else
    log.v("query: " .. hs.inspect(query))
    latestQuery = query
    queryDelay:start()
  end
end

module.compileChoices = function()
  local mapOfChoices = {}
  local numberOfSources = 0
  local useFzf = false

  log.v("compiling choices from plugins")
  for requireName, plugin in pairs(plugins) do
    if plugin.keyword == activeKeyword then
      local pluginChoices = plugin.compileChoices(latestQuery)
      useFzf = useFzf or plugin.useFzf
      if #pluginChoices > 0 then
        -- considering this a plain list of choices and adding to our map
        mapOfChoices[requireName] = pluginChoices
        numberOfSources = numberOfSources + 1
      else
        -- must be either empty or a map of tables, this works either way
        for k, v in pairs(pluginChoices) do
          mapOfChoices[k] = v
          numberOfSources = numberOfSources + 1
        end
      end
    end
  end
  log.v("compiled choices from plugins", hs.inspect({ sources = numberOfSources, useFzf = useFzf }))

  if numberOfSources == 1 and not useFzf then
    -- special case, likely plugin with keyword
    for _, choices in pairs(mapOfChoices) do
      return choices
    end
  end

  -- use fzf to combine sources
  local fzfInputPath = hs.fs.temporaryDirectory() .. "fzf-input-" .. hs.host.uuid()
  local fzfInput = io.open(fzfInputPath, "w")
  if not fzfInput then
    log.ef("can't open fzf input file for writing: %s", fzfInputPath)
    return {}
  end

  local lookup = {}
  for _, choices in pairs(mapOfChoices) do
    for _, choice in ipairs(choices) do
      fzfInput:write(choice.id .. "\t" .. choice.text .. "\n")
      lookup[choice.id] = choice
    end
  end
  fzfInput:close()

  local command =
    string.format("%s -i --delimiter '\t' --with-nth -1 --filter '%s' < %s", FZF_PATH, latestQuery, fzfInputPath)
  local fzf = io.popen(command)
  if not fzf then
    log.ef("can't read output of fzf")
    os.remove(fzfInputPath)
    return {}
  end

  local choices = {}
  for line in fzf:lines() do
    local id = line:match("([^\t]*)")
    if id and lookup[id] then
      table.insert(choices, lookup[id])
    end
  end
  fzf:close()
  os.remove(fzfInputPath)

  return choices
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))

  if choice and choice.source then
    local plugin = plugins[choice.source]
    if plugin then
      plugin.complete(choice)
    else
      log.ef("can't find plugin source for choice: %s", hs.inspect(choice.source))
    end
  end
end

module.shown = function()
  log.v("shown")
end

module.hidden = function()
  log.v("hidden")
end

module.invalid = function(choice)
  log.v("invalid choice: " .. hs.inspect(choice))
end

module.rightClicked = function(row)
  log.v("right clicked row: " .. hs.inspect(row))
end

module.toggle = function()
  if chooser:isVisible() then
    log.v("closing")
    queryDelay:stop()
    chooser:hide()
  else
    log.v("opening")
    activeKeyword = nil
    chooser:query(nil)
    chooser:show()
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
