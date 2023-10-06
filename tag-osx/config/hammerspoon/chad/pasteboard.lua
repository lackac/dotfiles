local trimForDisplay = require("ext.utils").trimForDisplay

local cache = { appIcons = {} }
local module = {
  keyword = "pb",
  useFzf = true,
  fzfOpts = "--tac --no-sort --scheme=history --tiebreak=index",
  cache = cache,
  placeholder = "",
  tip = { text = "pb⇥ to search the pasteboard history" },
}

local log

local history
local watcher
local historyMaxSize = 500

-- see http://nspasteboard.org/
local filterIds = {
  ["de.petermaurer.TransientPasteboardType"] = true,
  ["com.typeit4me.clipping"] = true,
  ["Pasteboard generator type"] = true,
  ["com.agilebits.onepassword"] = true,
  ["org.nspasteboard.TransientType"] = true,
  ["org.nspasteboard.ConcealedType"] = true,
  ["org.nspasteboard.AutoGeneratedType"] = true,
}

local function shouldFilter()
  return hs.fnutils.some(hs.pasteboard.contentTypes(), function(t)
    return filterIds[t]
  end) or hs.fnutils.some(hs.pasteboard.pasteboardTypes(), function(t)
    return filterIds[t]
  end)
end

local function sourceAppImage(bundleId)
  if not cache.appIcons[bundleId] then
    cache.appIcons[bundleId] = hs.image.imageFromAppBundle(bundleId)
  end
  return cache.appIcons[bundleId]
end

local function trimHistory()
  local size = #history
  if size > historyMaxSize then
    local trimmed = {}
    table.move(history, size - historyMaxSize + 1, size, 1, trimmed)
    history = trimmed
  end
end

local function savePasteboardContents(text)
  if text and not shouldFilter() then
    local sourceApp = hs.pasteboard.readDataForUTI("org.nspasteboard.source")
      or hs.application.frontmostApplication():bundleID()
    local uti = hs.pasteboard.contentTypes()[1]

    local trimmed, full = trimForDisplay(text)

    local item = {
      text = trimmed,
      fullText = full,
      sourceApp = sourceApp,
      uti = uti,
      time = os.time(),
    }
    log.v("new content", hs.inspect(item))

    table.insert(history, item)

    if #history > historyMaxSize * 1.5 then
      trimHistory()
    end
  end
end

local function decorateWithMeta(list)
  for _, item in ipairs(list) do
    if not item.id then
      item.id = hs.host.uuid()
      item.source = module.requireName
      item.subText = os.date("%b %d @ %H:%M", item.time)
      if item.sourceApp then
        item.image = sourceAppImage(item.sourceApp)
        local appName = hs.application.nameForBundleID(item.sourceApp)
        if appName then
          item.subText = item.subText .. " from " .. appName
        end
      end
    end
  end
end

local function withoutMeta(list)
  local cleaned = {}
  local filterKeys = {
    image = true,
    source = true,
    subText = true,
    id = true,
  }

  for _, item in ipairs(list) do
    local cleanedItem = {}
    for k, v in pairs(item) do
      if not filterKeys[k] then
        cleanedItem[k] = v
      end
    end
    table.insert(cleaned, cleanedItem)
  end

  return cleaned
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))
  decorateWithMeta(history)
  return history
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice then
    hs.pasteboard.writeAllData({
      ["public.utf8-plain-text"] = choice.fullText or choice.text,
      ["org.nspasteboard.source"] = choice.sourceApp,
    })
    hs.timer.waitWhile(module.main.chooserWindow, function()
      hs.eventtap.keyStroke({ "cmd" }, "v")
    end, 0.2)
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "debug")

  history = hs.settings.get(module.requireName .. ":history") or {}

  watcher = hs.pasteboard.watcher.new(savePasteboardContents):start()
end

module.stop = function()
  watcher:stop()
  watcher = nil

  trimHistory()
  hs.settings.set(module.requireName .. ":history", withoutMeta(history))
  history = nil
end

return module
