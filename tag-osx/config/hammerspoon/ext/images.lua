local capture = require("ext.utils").capture

local cache = { paths = {}, progressIcons = {}, flags = {} }
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

  local glyphs = {}
  local allGlyphs = capture(nerdFontsPath)
  if not allGlyphs or allGlyphs == "" then
    log.e("couldn't list Nerd Fonts glyphs")
    return
  end

  for glyph, groupKey, name in allGlyphs:gmatch("([^\n]*)\t([^\n]*)\t([^\n]*)") do
    local group = nerdFontsGroups[groupKey]
    if not group then
      log.wf("unknown Nerd Fonts group '%s'", groupKey)
    end

    table.insert(glyphs, {
      name = name,
      id = groupKey .. "-" .. name,
      groupKey = groupKey,
      group = group,
      glyph = glyph,
    })
  end

  cache.nerdFontsGlyphs = glyphs
  return glyphs
end

module.nerdFontsIcon = function(glyph, color)
  color = color or "black"

  local image = renderGlyph(glyph, "nerd-fonts", {
    color = color,
    textFont = "Symbols Nerd Font",
  })
  return image
end

-- Emoji
local emojiDatabaseUrl = "https://unicode.org/Public/emoji/latest/emoji-test.txt"

module.emojis = function()
  if cache.emojis then
    return cache.emojis
  end

  local emojis = {}

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

  cache.emojis = emojis
  return emojis
end

module.emojiIcon = function(emoji)
  local image = renderGlyph(emoji, "emojis")
  return image
end

local flagExceptions = {
  CS = "CZ",
  DA = "DK",
  EL = "GR",
  JA = "JP",
  KO = "KR",
  NB = "NO",
  UK = "UA",
  ZH = "CH",
}

module.flagIcon = function(code)
  if code == nil or code == "" then
    return
  end

  code = string.upper(code)

  local countryCode = code:match("[_-]([A-Z][A-Z])$")
  if countryCode then
    code = countryCode
  end

  code = flagExceptions[code] or code

  if not cache.flags[code] then
    local a, b = string.byte(code, 1, 2)
    -- see https://en.wikipedia.org/wiki/Regional_indicator_symbol
    local flagCode = utf8.char(a + 0x1F1E6 - 65, b + 0x1F1E6 - 65)
    cache.flags[code] = module.emojiIcon(flagCode)
  end

  return cache.flags[code]
end

-- Generic icon generator based on the glyph
module.icon = function(glyph, color)
  local bytes = table.pack(string.byte(glyph, 1, -1))
  if bytes[1] == 238 or bytes[1] == 239 or bytes[1] == 243 then
    return module.nerdFontsIcon(glyph, color)
  elseif bytes[1] == 226 then
    if glyph == "⏻" or glyph == "⏼" or glyph == "⏽" or glyph == "⏾" or glyph == "♥" or glyph == "⭘" then
      return module.nerdFontsIcon(glyph, color)
    else
      return module.emojiIcon(glyph)
    end
  else
    return module.emojiIcon(glyph)
  end
end

-- Progress
local progressGlyphs = { " ", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

module.progressIcon = function(percent)
  percent = percent or 0
  local index = 1 + math.floor(percent / 12.5)

  if not cache.progressIcons[index] then
    cache.progressIcons[index] = module.nerdFontsIcon(progressGlyphs[index], "forestgreen")
  end

  return cache.progressIcons[index]
end

return module
