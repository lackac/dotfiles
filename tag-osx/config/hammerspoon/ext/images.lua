local capture = require("ext.utils").capture

local cache = { paths = {} }
local module = { cache = cache }

local log = hs.logger.new("ext.images", "debug")

-- common helpers for rendering glyphs
local glyphCanvas = hs.canvas.new({ x = 0, y = 0, w = 96, h = 96 })

local function cachePath(dir)
  if cache.paths[dir] then
    return cache.paths[dir]
  else
    local path = os.getenv("HOME") .. "/Library/Caches/" .. hs.settings.bundleID .. "/" .. dir
    hs.fs.mkdir(path)
    cache.paths[dir] = path
    return path
  end
end

local function glyphToCodepoints(glyph)
  local codepoints = ""
  for _, c in utf8.codes(glyph) do
    codepoints = string.format("%s%s%X", codepoints, codepoints == "" and "" or "-", c)
  end
  return codepoints
end

local function renderGlyph(glyph, color, cacheDir, attributes)
  local imagePath = cachePath(cacheDir) .. "/" .. glyphToCodepoints(glyph)
  if color then
    imagePath = imagePath .. "-" .. color
  end
  imagePath = imagePath .. ".png"

  local image = hs.image.imageFromPath(imagePath)
  if not image then
    glyphCanvas[1] = {
      type = "text",
      text = glyph,
      textSize = 64,
      frame = { x = "15%", y = "10%", w = "100%", h = "100%" },
    }
    if color then
      glyphCanvas[1].textColor = hs.drawing.color.x11[color]
    end
    if attributes then
      for k, v in pairs(attributes) do
        glyphCanvas[1][k] = v
      end
    end
    image = glyphCanvas:imageFromCanvas()
    image:saveToFile(imagePath)
  end

  return image
end

-- Nerd Fonts
local nerdFontsPath = os.getenv("HOME") .. "/bin/nerd-fonts"

local nerdFontsGroups = {
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

module.nerdFontsGlyphs = function()
  if cache.nerdFontsGlyphs then
    return cache.nerdFontsGlyphs
  end

  local settingsKey = "nerdFonts:nameToGlyph"
  local nameToGlyph = hs.settings.get(settingsKey)

  if not nameToGlyph then
    local allGlyphs = capture(nerdFontsPath)
    if not allGlyphs or allGlyphs == "" then
      log.e("couldn't list Nerd Fonts glyphs")
      return
    end

    nameToGlyph = {}
    for glyph, groupKey, name in allGlyphs:gmatch("([^\n]*)\t([^\n]*)\t([^\n]*)") do
      local group = nerdFontsGroups[groupKey]
      if not group then
        log.wf("unknown Nerd Fonts group '%s'", groupKey)
      end

      local id = groupKey .. "-" .. name

      nameToGlyph[id] = {
        name = name,
        groupKey = groupKey,
        group = group,
        glyph = glyph,
      }
    end
    hs.settings.set(settingsKey, nameToGlyph)
  end

  cache.nerdFontsGlyphs = nameToGlyph
  return nameToGlyph
end

module.nerdFontsIcon = function(glyph, color)
  color = color or "black"

  if glyph:match("^[a-z]") then
    glyph = module.nerdFontsGlyphs()[glyph]
  end

  local image = renderGlyph(glyph, color, "nerd-fonts", {
    textFont = "FiraCode Nerd Font",
  })
  return image
end

return module
