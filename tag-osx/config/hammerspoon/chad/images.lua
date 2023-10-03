local cache = {}
local module = {
  keyword = "i",
  useFzf = true,
  cache = cache,
  placeholder = "search for builtin images",
  tip = { text = "type i⇥ to search builtin icons" },
}

local log

local function cacheImages()
  cache.images = {}

  for key, name in pairs(hs.image.systemImageNames) do
    table.insert(cache.images, {
      text = key,
      subText = name,
      id = name,
      image = hs.image.imageFromName(name),
      source = module.requireName,
    })
  end
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  return cache.images
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice and choice.subText then
    hs.pasteboard.setContents(choice.subText)
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "debug")

  cacheImages()
end

module.stop = function() end

return module
