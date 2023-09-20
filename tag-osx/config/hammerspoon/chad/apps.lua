local cache = { choices = {} }
local module = {
  useFzf = true,
  cache = cache,
}

local log

local home = os.getenv("HOME")
local searchPaths = {
  "/Applications",
  "/Applications/Setapp",
  "/System/Applications",
  "/System/Applications/Utilities",
  home .. "/Applications",
  "/System/Library/PreferencePanes",
  "/Library/PreferencePanes",
  home .. "/Library/PreferencePanes",
  "/System/Library/CoreServices",
  "/System/Library/CoreServices/Applications",
}

local function load(key)
  return hs.settings.get(module.requireName .. ":" .. key) or {}
end

local function save(key, value)
  return hs.settings.set(module.requireName .. ":" .. key, value)
end

local function generateChoice(appInfo)
  return {
    text = appInfo.name,
    subText = appInfo.path,
    id = appInfo.path,
    source = module.requireName,
    image = hs.image.iconForFile(appInfo.path),
  }
end

local function loadApplications()
  local modTimes = load("modTimes")
  local appsByPath = load("appsByPath")
  local changed = false

  for _, path in ipairs(searchPaths) do
    local modTime = modTimes[path]
    local currentModTime = hs.fs.attributes(path, "modification")

    if modTime == nil or currentModTime > modTime then
      changed = true
      appsByPath[path] = {}
      cache.choices[path] = {}
      for app in hs.fs.dir(path) do
        local name, ext = string.match(app, "^(.*)%.(.*)$")
        if ext == "app" or ext == "prefPane" then
          local fullPath = path .. "/" .. app
          local appInfo = { name = name, path = fullPath }
          table.insert(appsByPath[path], appInfo)
          table.insert(cache.choices[path], generateChoice(appInfo))
        end
      end
      modTimes[path] = currentModTime
    elseif cache.choices[path] == nil then
      cache.choices[path] = {}
      for _, appInfo in ipairs(appsByPath[path]) do
        table.insert(cache.choices[path], generateChoice(appInfo))
      end
    end
  end

  if changed then
    save("modTimes", modTimes)
    save("appsByPath", appsByPath)
  end
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  if query ~= "" then
    return cache.choices
  else
    return {}
  end
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  hs.open(choice.subText)
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "verbose")

  loadApplications()
end

module.stop = function() end

module.reloadApplications = function()
  save("modTimes", {})
  cache.choices = {}
  loadApplications()
end

return module
