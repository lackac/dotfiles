local dictionary = require("hs.dictionary")
local images = require("ext.images")

local cache = { flags = {} }
local module = {
  keyword = "define",
  useFzf = true,
  cache = cache,
  tip = { text = "def⇥ to find definition of words" },
}

local log

local iconColor = "brown"
local defineIcon = images.nerdFontsIcon("󰘝", iconColor)

local function showPanel(title, html)
  local chooserWindow = module.main.chooserWindow()
  local chooserFrame = chooserWindow:frame()
  local frame = chooserWindow:frame():move({ chooserFrame.w + 8, 0 }):intersect(chooserWindow:screen():frame())

  if not cache.webview then
    log.v("creating webview")
    cache.webview = hs.webview
      .new(frame)
      :closeOnEscape(true)
      :deleteOnClose(true)
      :windowStyle({ "borderless", "titled", "closable", "resizable" })
      :windowCallback(function(event, wv, meta)
        log.v("webview window callback" .. hs.inspect({ event, wv, meta }))
      end)
  else
    cache.webview:windowTitle(title):html(html)
    if not cache.webview:isVisible() then
      cache.webview:frame(frame):show():bringToFront()
    end
  end
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))

  if #query > 1 then
    local definitions = dictionary.lookup(query, { matching = "prefix", format = "htmlForApp" })
    local choices = {}
    for i, def in ipairs(definitions) do
      table.insert(choices, {
        text = def.text,
        subText = (def.title or def.headword) .. " – " .. def.dictionary,
        html = def.definition,
        id = "def:" .. i .. ":" .. def.headword,
        source = module.requireName,
        image = images.flagIcon(def.language) or defineIcon,
        valid = false,
      })
    end
    return choices
  else
    return {}
  end
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice.id))
end

module.invalid = function(choice)
  log.v("invalid choice: " .. hs.inspect(choice.id))
  if choice and choice.html then
    showPanel(choice.subText, choice.html)
  end
end

module.deactivate = function()
  log.v("deactivating plugin")
  if cache.webview and cache.webview:isVisible() then
    cache.webview:hide()
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "verbose")
end

module.stop = function() end

return module
