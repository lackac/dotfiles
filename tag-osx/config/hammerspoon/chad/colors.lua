local cache = {}
local module = {
  keyword = "c",
  useFzf = true,
  cache = cache,
  placeholder = "search for x11 color names",
  tip = { text = "type c⇥ to search x11 color names" },
}

local log

local function cacheColors()
  cache.choices = {}

  log.d("caching x11 color choices")

  for color, _ in pairs(hs.drawing.color.x11) do
    local id = "x11" .. ":" .. color
    table.insert(cache.choices, {
      text = hs.styledtext.new(color, { font = { size = 18 }, color = hs.drawing.color.x11[color] }),
      id = id,
      source = module.requireName,
    })
  end

  log.df("cached %d x11 colors", #cache.choices)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  return cache.choices
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice then
    hs.pasteboard.setContents(choice.text:getString())
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "debug")

  cacheColors()
end

module.stop = function() end

return module
