local smartLaunchOrFocus = require("ext.application").smartLaunchOrFocus
local system = require("ext.system")
local window = require("ext.window")
local unescape = require("ext.utils").unescape
local config = require("config")

local module = {}
local log = hs.logger.new("drop-cli", "debug")

local DROP_CLI_PATH = os.getenv("HOME") .. "/bin/drop-cli"

-- when cmd+v is broken
local forcePaste = function()
  local contents = hs.pasteboard.getContents()

  if not contents then
    return
  end

  hs.eventtap.keyStrokes(contents)
end

local startsWith = function(str, start)
  return str:sub(1, #start) == start
end

local logDrop = function(_, out, err)
  if #err > 0 then
    log.e(err)
  end

  log.d(out)
end

-- fake drop item
local forceDrop = function()
  local data = hs.pasteboard.readAllData()
  local fileUrl = data["public.file-url"]
  local arguments = {}

  if fileUrl == nil then
    local filePath = hs.pasteboard.getContents() or ""

    -- removing double quotes if necessary
    if startsWith(filePath, "'") then
      filePath = filePath:match("^'(.*)'$")
    end

    arguments = { filePath }
  else
    local filePath = unescape(fileUrl):gsub("file://", "")
    local plainText = data["public.utf8-plain-text"]

    if plainText ~= nil then
      local fileNames = hs.fnutils.split(plainText, "\r")
      local folderPath = filePath:match("(.*/)")

      arguments = hs.fnutils.map(fileNames, function(fileName)
        return folderPath .. fileName
      end)
    else
      arguments = { filePath }
    end
  end

  if #arguments > 0 then
    hs.task.new(DROP_CLI_PATH, logDrop, arguments):start()
  else
    log.e("emtpy arguments", hs.inspect(data))
  end
end

module.start = function()
  -- Alfred replacement implemented fully in Hammerspoon
  require("chad"):start()
  hs.hotkey.bind({ "ctrl" }, "space", function()
    require("chad").toggle()
  end)
  hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "space", function()
    require("chad").reload()
  end)

  hs.fnutils.each({
    { key = "c", keyword = "pb" },
    { key = "s", keyword = "s" },
    { key = "t", keyword = "tr" },
  }, function(object)
    hs.hotkey.bind({ "ctrl", "cmd" }, object.key, function()
      require("chad").showWithKeyword(object.keyword)
    end)
  end)

  -- toggles
  hs.fnutils.each({
    { key = "/", fn = system.toggleConsole },
    { key = "q", fn = system.displaySleep },
    { key = "r", fn = hs.reload },
    { key = "r", mod = { "shift" }, fn = hs.relaunch },

    { key = "d", fn = forceDrop },
    { key = "v", fn = forcePaste },

    { key = "t", mod = { "shift" }, fn = system.toggleTheme },
    { key = "w", fn = system.toggleWiFi },
  }, function(object)
    hyper:bind(object.mod or {}, object.key, object.fn)
  end)

  -- apps
  hs.fnutils.each({
    { key = "return", apps = config.apps.terms },
    { key = "space", apps = config.apps.browsers },
    { key = "b", apps = config.apps.browsers },
    { key = ",", apps = { "System Settings" } },
    { key = "s", apps = { "Slack" } },
    { key = "f", apps = { "Finder" } },
  }, function(object)
    hyper:bind({}, object.key, function()
      smartLaunchOrFocus(object.apps)
    end)
  end)
end

module.stop = function()
  require("chad"):stop()
end

return module
