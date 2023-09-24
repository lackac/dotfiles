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

local function cacheEmojis()
  cache.choices = {}

  log.d("caching Emojis")

  local emojis = images.emojis() or {}

  for _, e in ipairs(emojis) do
    table.insert(cache.choices, {
      text = e.description,
      subText = e.group .. " > " .. e.subGroup,
      emoji = e.emoji,
      id = e.id,
      source = module.requireName,
      image = images.emojiIcon(e.emoji),
    })
  end

  log.df("cached %d emojis", #cache.choices)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  if cache.choices == nil or #cache.choices == 0 then
    cacheEmojis()
  end
  return cache.choices
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
  log = hs.logger.new(module.requireName, "verbose")
end

module.stop = function() end

return module
