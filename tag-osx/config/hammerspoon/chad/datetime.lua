local emojiIcon = require("ext.images").emojiIcon

local cache = { clockImages = {} }
local module = {
  keyword = "d",
  useFzf = false,
  cache = cache,
  placeholder = "select a representation or enter format string",
  tip = { text = "type d⇥ for formatted date and time" },
}

local log

local clockEmojis = {
  "🕛",
  "🕧",
  "🕐",
  "🕜",
  "🕑",
  "🕝",
  "🕒",
  "🕞",
  "🕓",
  "🕟",
  "🕔",
  "🕠",
  "🕕",
  "🕡",
  "🕖",
  "🕢",
  "🕗",
  "🕣",
  "🕘",
  "🕤",
  "🕙",
  "🕥",
  "🕚",
  "🕦",
}

local function clockImage(time)
  time = time or os.date("*t")
  local clockIndex = 1 + math.floor((time.hour % 12 + time.min / 60) * 2 + 0.5)

  if not cache.clockImages[clockIndex] then
    cache.clockImages[clockIndex] = emojiIcon(clockEmojis[clockIndex])
  end

  return cache.clockImages[clockIndex]
end

local defaultFormats = {
  "%F",
  "%T",
  "%FT%T%z",
  "%F %T %z",
  "%A, %B %d, %Y",
  "%a, %b %d, %Y",
  "%m/%d/%y %H:%M",
  "%c",
}

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))

  query = query or ""

  if query ~= "" and query ~= "!" then
    local _, result = pcall(os.date, query)
    return {
      {
        text = result,
        id = "datetime-result-1",
        source = module.requireName,
        image = clockImage(),
      },
    }
  else
    local clockImageNow = clockImage(os.date(query .. "*t"))
    local choices = {}

    for i, format in ipairs(defaultFormats) do
      local formatted = os.date(query .. format)
      table.insert(choices, {
        text = formatted,
        id = "datetime-result-" .. i,
        source = module.requireName,
        image = clockImageNow,
      })
    end

    return choices
  end
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice then
    hs.pasteboard.setContents(choice.text)
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "debug")
end

module.stop = function() end

return module
