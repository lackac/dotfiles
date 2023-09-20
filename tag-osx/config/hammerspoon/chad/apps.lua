local cache = {}
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
  "/System/Library/CoreServices/",
  "/System/Library/CoreServices/Applications",
}

local function load(key)
  return hs.settings.get(module.requireName .. ":" .. key) or {}
end

local function save(key, value)
  return hs.settings.set(module.requireName .. ":" .. key, value)
end

local function loadApplications()
  local modTimes = load("modTimes")
  local appsByPath = load("appsByPath")

  for _, path in ipairs(searchPaths) do
    local modTime = modTimes[path]
    local currentModTime = hs.fs.attributes(path, "modification")

    if modTime == nil or currentModTime > modTime then
      appsByPath[path] = {}
      for app in hs.fs.dir(path) do
        local name, ext = string.match(app, "^(.*)%.(.*)$")
        if ext == "app" or ext == "prefPane" then
          local fullPath = path .. "/" .. app
          table.insert(appsByPath[path], {
            text = name,
            subText = fullPath,
            id = fullPath,
            source = module.requireName,
          })
        end
      end
      modTimes[path] = currentModTime
    end

    cache.appsByPath = appsByPath
  end

  save("modTimes", modTimes)
  save("appsByPath", appsByPath)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  if query ~= "" then
    return cache.appsByPath
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

return module
