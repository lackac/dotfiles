local cache = {}
local module = {
  keyword = "kw",
  useFzf = true,
  cache = cache,
  placeholder = "show this when the keyword is activated",
  tip = { text = "type kw⇥ to activate this plugin" },
}

local log

local function cacheChoices()
  cache.choices = {}

  log.d("caching choices")

  -- some expensive processing

  log.df("cached %d choices", #cache.choices)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  if cache.choices == nil or #cache.choices == 0 then
    cacheChoices()
  end
  return cache.choices
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice then
    hs.pasteboard.setContents(choice.text)
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "verbose")
end

module.stop = function() end

return module
