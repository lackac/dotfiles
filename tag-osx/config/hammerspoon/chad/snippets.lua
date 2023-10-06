local icon = require("ext.images").icon
local trimForDisplay = require("ext.utils").trimForDisplay

local cache = { icons = {} }
local module = {
  keyword = "s",
  useFzf = true,
  cache = cache,
  placeholder = "search the snippets library",
  tip = { text = "s⇥ to access snippets" },
}

local log

local function iconImage(glyph)
  if not glyph then
    return
  end

  if not cache.icons[glyph] then
    cache.icons[glyph] = icon(glyph, "dimgray")
  end

  return cache.icons[glyph]
end

local function addToCache(fullPath)
  local _, name, ext = fullPath:match("^(.*)/(.*)%.([^.]+)$")
  if ext ~= "json" then
    return
  end

  local contents = hs.json.read(fullPath)
  if contents then
    local snippets = {}
    for key, value in pairs(contents) do
      if key:sub(1, 1) ~= "_" then
        table.insert(snippets, {
          text = name .. " " .. key,
          subText = trimForDisplay(value),
          fullText = value,
          fzfInput = name .. " " .. key,
          id = "snippets:" .. name .. "." .. key,
          source = module.requireName,
          image = iconImage(contents._icon),
        })
      end
    end
    cache.files[name] = snippets
  else
    log.wf("couldn't read snippets from file '%s'", fullPath)
  end
end

local function cacheChoices()
  local path = module.main.path .. "/snippets"
  local totalChoices = 0

  cache.files = {}

  log.d("caching choices")

  for file in hs.fs.dir(path) do
    addToCache(path .. "/" .. file)
  end

  log.df("cached %d choices", totalChoices)

  if not cache.watcher then
    cache.watcher = hs.pathwatcher
      .new(path, function(paths, flags)
        log.v("pathwatcher", hs.inspect({ paths, flags }))
        for i, f in ipairs(flags) do
          if f.itemIsFile then
            if f.itemCreated or f.itemModified then
              addToCache(paths[i])
            elseif f.itemRemoved then
              local _, name, ext = paths[i]:match("^(.*)/(.*)%.([^.]+)$")
              if ext == "json" and cache.files[name] then
                cache.files[name] = nil
              end
            end
          end
        end
      end)
      :start()
  end
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  if not cache.files then
    cacheChoices()
  end
  return cache.files
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice then
    hs.pasteboard.setContents(choice.fullText or choice.text)
    hs.timer.waitWhile(module.main.chooserWindow, function()
      hs.eventtap.keyStroke({ "cmd" }, "v")
    end, 0.2)
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "debug")
end

module.stop = function()
  if cache.watcher then
    cache.watcher:stop()
    cache.watcher = nil
  end
end

return module
