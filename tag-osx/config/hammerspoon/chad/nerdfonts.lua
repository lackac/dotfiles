local capture = require("ext.utils").capture

local cache = {}
local module = {
  keyword = "nf",
  useFzf = true,
  cache = cache,
  placeholder = "search for nerd font characters",
  tip = { text = "type nf↦ to search nerd font characters" },
}

local log

local nerdfontsPath = os.getenv("HOME") .. "/bin/nerdfonts"
local nerdfontsGroups = {
  cod = "Codicons",
  dev = "Devicons",
  fa = "Font Awesome",
  fae = "Font Awesome Extension",
  iec = "IEC Power Symbols",
  indent = "Indentation",
  indentation = "Indentation",
  linux = "Logos",
  md = "Material Design Icons",
  oct = "Octicons",
  pl = "Powerline Symbols",
  ple = "Powerline Extra Symbols",
  pom = "Pomicons",
  seti = "Seti-UI",
  custom = "Custom",
  weather = "Weather Icons",
}

local canvas = hs.canvas.new({ x = 0, y = 0, w = 96, h = 96 })

local cachePath = os.getenv("HOME") .. "/Library/Caches/" .. hs.settings.bundleID .. "/nerdfonts"
hs.fs.mkdir(cachePath)

local function nfImage(id, char, color)
  color = color or "black"
  local imagePath = cachePath .. "/" .. id .. "-" .. color .. ".png"
  local image = hs.image.imageFromPath(imagePath)
  if not image then
    canvas[1] = {
      type = "text",
      textFont = "FiraCode Nerd Font",
      text = char,
      textSize = 64,
      textColor = hs.drawing.color.x11[color],
      frame = { x = "15%", y = "10%", w = "100%", h = "100%" },
    }
    image = canvas:imageFromCanvas()
    image:saveToFile(imagePath)
  end
  return image
end

local function cacheNerdFonts()
  cache.choices = {}

  log.d("caching nerdfonts characters")

  local allChars = hs.settings.get(module.requireName .. ":nerdfonts-chars")
  if not allChars then
    allChars = capture(nerdfontsPath)
    hs.settings.set(module.requireName .. ":nerdfonts-chars", allChars)
  end

  if not allChars or allChars == "" then
    log.e("couldn't list nerdfonts")
    return
  end

  for character, groupKey, description in allChars:gmatch("([^\n]*)\t([^\n]*)\t([^\n]*)") do
    local group = nerdfontsGroups[groupKey]
    if not group then
      log.wf("unknown nerd fonts group '%s'", groupKey)
    end

    local id = groupKey .. "-" .. description
    table.insert(cache.choices, {
      text = description,
      subText = group or groupKey,
      character = character,
      id = id,
      source = module.requireName,
      image = nfImage(id, character, "darkblue"),
    })
  end

  log.df("cached %d nerdfonts characters", #cache.choices)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  return cache.choices
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice then
    if choice.character then
      hs.pasteboard.setContents(choice.character)
    else
      log.wf("couldn't find character attribute on choice: %s", hs.inspect(choice))
    end
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "verbose")

  cacheNerdFonts()
end

module.stop = function() end

return module
