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

local databaseUrl = "https://unicode.org/Public/emoji/latest/emoji-test.txt"
local canvas = hs.canvas.new({ x = 0, y = 0, w = 96, h = 96 })

local cachePath = os.getenv("HOME") .. "/Library/Caches/" .. hs.settings.bundleID .. "/emoji"
hs.fs.mkdir(cachePath)

local function emojiImage(codepoints, emoji)
  local imagePath = cachePath .. "/" .. codepoints .. ".png"
  local image = hs.image.imageFromPath(imagePath)
  if not image then
    canvas[1] = { type = "text", text = emoji, textSize = 64, frame = { x = "15%", y = "10%", w = "100%", h = "100%" } }
    image = canvas:imageFromCanvas()
    image:saveToFile(imagePath)
  end
  return image
end

local function cacheEmojis()
  cache.choices = {}

  log.d("downloading emoji database")
  hs.http.asyncGet(databaseUrl, nil, function(status, body, _)
    if status == 200 then
      log.d("downloaded emoji database")
      local group
      local subGroup

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
          table.insert(cache.choices, {
            text = description,
            subText = group .. " > " .. subGroup,
            emoji = emoji,
            id = codepoints,
            source = module.requireName,
            image = emojiImage(codepoints, emoji),
          })
        end
      end
      log.df("cached %d emojis", #cache.choices)
    else
      log.ef("couldn't download emoji database: %d\n%s", status, body)
    end
  end)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
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

  cacheEmojis()
end

module.stop = function() end

return module
