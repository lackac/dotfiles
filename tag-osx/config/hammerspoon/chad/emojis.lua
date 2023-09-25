local images = require("ext.images")

local cache = {}
local module = {
  keyword = ":",
  autoActivate = true,
  useFzf = true,
  cache = cache,
  placeholder = "search for emoji characters",
  tip = { text = "type : to search emoji characters" },
}

local log
local emojiCacher

local function cacheEmojis()
  if emojiCacher and coroutine.status(emojiCacher) ~= "dead" then
    return
  end

  cache.choices = {}
  cache.totalChoices = 0
  local cachingStart = hs.timer.secondsSinceEpoch()

  emojiCacher = coroutine.create(function()
    log.d("caching Emojis")

    local emojis = images.emojis() or {}
    cache.totalChoices = #emojis

    for i, e in ipairs(emojis) do
      if i % 10 == 1 then
        coroutine.applicationYield()
      end
      table.insert(cache.choices, {
        text = e.description,
        subText = e.group .. " > " .. e.subGroup,
        emoji = e.emoji,
        id = e.id,
        source = module.requireName,
        image = images.emojiIcon(e.emoji),
      })
    end

    local elapsedTime = hs.timer.secondsSinceEpoch() - cachingStart
    log.df("cached %d emojis in %.2f seconds", #cache.choices, elapsedTime)
    module.main.chooser:refreshChoicesCallback()
  end)

  coroutine.resume(emojiCacher)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))

  if cache.choices == nil or #cache.choices == 0 then
    cacheEmojis()
  end

  if emojiCacher and coroutine.status(emojiCacher) ~= "dead" then
    local progress = cache.totalChoices
        and cache.totalChoices > 0
        and math.floor(#cache.choices / cache.totalChoices * 100)
      or 0

    hs.timer.doAfter(0.25, function()
      module.main.chooser:refreshChoicesCallback()
    end)
    return {
      {
        text = string.format("Loading emojis %d%% [%d / %d]", progress, #cache.choices, cache.totalChoices or 0),
        valid = false,
        id = module.requireName .. "-progress",
        source = module.requireName,
        image = images.progressIcon(progress),
      },
    }
  else
    return cache.choices or {}
  end
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice then
    if choice.emoji then
      hs.pasteboard.setContents(choice.emoji)
    else
      log.wf("couldn't find emoji attribute on choice: %s", hs.inspect(choice))
    end
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "debug")
end

module.stop = function() end

return module
