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

local function renderGlyph(glyph, cacheDir, attributes)
  attributes = attributes or {}

  local imagePath = cachePath(cacheDir) .. "/" .. glyphToCodepoints(glyph)
  if attributes.color then
    imagePath = imagePath .. "-" .. attributes.color
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
    if attributes.color then
      glyphCanvas[1].textColor = hs.drawing.color.x11[attributes.color]
      attributes.color = nil
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

  local settingsKey = "ext.images:nerdFontsGlyphs"
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

  local image = renderGlyph(glyph, "nerd-fonts", {
    color = color,
    textFont = "FiraCode Nerd Font",
  })
  return image
end

-- Emoji
local emojiDatabaseUrl = "https://unicode.org/Public/emoji/latest/emoji-test.txt"

module.emojis = function()
  if cache.emojis then
    return cache.emojis
  end

  local settingsKey = "ext.images:emojis"
  local emojis = hs.settings.get(settingsKey)

  if not emojis then
    log.d("downloading emoji database")
    local status, body, _ = hs.http.get(emojiDatabaseUrl)

    if status == 200 then
      log.d("downloaded emoji database")
      local group
      local subGroup
      emojis = {}

      for line in body:gmatch("([^\n]*)\n") do
        local level, groupName = line:match("^# ([sub]*group): (.*)")
        local codepoints, emoji, description =
          line:match("^([A-F0-9][A-Z0-9 ]+[A-Z0-9]) *; fully%-qualified *# (%S+) E%d+%.%d+ (.*)$")
        if level == "group" then
          group = groupName
        elseif level == "subgroup" then
          subGroup = groupName
        elseif codepoints then
          codepoints = codepoints:gsub(" ", "-")
          table.insert(emojis, {
            emoji = emoji,
            description = description,
            group = group,
            subGroup = subGroup,
            id = codepoints,
          })
        end
      end
    else
      log.ef("couldn't download emoji database: %d\n%s", status, body)
      return
    end

    hs.settings.set(settingsKey, emojis)
  end

  cache.emojis = emojis
  return emojis
end

module.emojiIcon = function(emoji)
  local image = renderGlyph(emoji, "emojis")
  return image
end

return module
