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
local nerdFontsCacher

local function cacheNerdFonts()
  if nerdFontsCacher and coroutine.status(nerdFontsCacher) ~= "dead" then
    return
  end

  cache.choices = {}
  cache.totalChoices = 0
  local cachingStart = hs.timer.secondsSinceEpoch()

  nerdFontsCacher = coroutine.create(function()
    log.d("caching Nerd Fonts glyphs")

    local nerdFontsGlyphs = images.nerdFontsGlyphs() or {}
    cache.totalChoices = #nerdFontsGlyphs

    for i, nf in ipairs(nerdFontsGlyphs) do
      if i % 10 == 1 then
        coroutine.applicationYield()
      end
      table.insert(cache.choices, {
        text = nf.name,
        subText = nf.group or nf.groupKey,
        glyph = nf.glyph,
        id = nf.id,
        source = module.requireName,
        image = images.nerdFontsIcon(nf.glyph, "brown"),
      })
    end

    local elapsedTime = hs.timer.secondsSinceEpoch() - cachingStart
    log.df("cached %d Nerd Fonts glyphs in %.2f seconds", #cache.choices, elapsedTime)
    module.main.chooser:refreshChoicesCallback()
  end)

  coroutine.resume(nerdFontsCacher)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))

  if cache.choices == nil or #cache.choices == 0 then
    cacheNerdFonts()
  end

  if nerdFontsCacher and coroutine.status(nerdFontsCacher) ~= "dead" then
    local progress = cache.totalChoices
        and cache.totalChoices > 0
        and math.floor(#cache.choices / cache.totalChoices * 100)
      or 0

    hs.timer.doAfter(0.25, function()
      module.main.chooser:refreshChoicesCallback()
    end)
    return {
      {
        text = string.format(
          "Loading Nerd Fonts glyphs %d%% [%d / %d]",
          progress,
          #cache.choices,
          cache.totalChoices or 0
        ),
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
    if choice.glyph then
      hs.pasteboard.setContents(choice.glyph)
    else
      log.wf("couldn't find glyph attribute on choice: %s", hs.inspect(choice))
    end
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "debug")
end

module.stop = function() end

return module
