local images = require("ext.images")

local cache = {}
local module = {
  keyword = "nf",
  useFzf = true,
  cache = cache,
  placeholder = "search for nerd fonts glyphs",
  tip = { text = "type nf⇥ to search nerd fonts glyphs" },
}

local log

local function cacheNerdFonts()
  cache.choices = {}

  log.d("caching Nerd Fonts characters")

  local nerdFontsGlyphs = images.nerdFontsGlyphs() or {}

  for id, nf in pairs(nerdFontsGlyphs) do
    table.insert(cache.choices, {
      text = nf.name,
      subText = nf.group or nf.groupKey,
      glyph = nf.glyph,
      id = id,
      source = module.requireName,
      image = images.nerdFontsIcon(nf.glyph, "brown"),
    })
  end

  log.df("cached %d Nerd Fonts glyphs", #cache.choices)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  if cache.choices == nil or #cache.choices == 0 then
    cacheNerdFonts()
  end
  return cache.choices
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice then
    if choice.glyph then
      hs.pasteboard.setContents(choice.glyph)
    else
      log.wf("couldn't find glyph attribute on choice: %s", hs.inspect(choice))
    end
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "verbose")
end

module.stop = function() end

return module
