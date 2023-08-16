local cache = { handlers = {}, ruleFiles = {}, ruleFileWatchers = {} }
local module = { cache = cache }
local log = hs.logger.new("urlevent", "warning")

local function appID(app)
  if hs.application.infoForBundlePath(app) then
    return hs.application.infoForBundlePath(app)["CFBundleIdentifier"]
  end
end

local function browserProfile(profile, browser)
  browser = browser or config.urls.defaultBrowser

  return function(url)
    hs.task.new("/usr/bin/open", nil, { "-n", "-a", browser, "--args", "--profile-directory=" .. profile, url }):start()
  end
end

local function findOrBuildHandler(target)
  if type(target) == "function" then
    return target
  elseif type(target) ~= "string" then
    return cache.handlers._default
  end

  if cache.handlers[target] ~= nil then
    return cache.handlers[target]
  end

  local profile = string.match(target, "^profile:(.*)")
  local id

  if profile ~= nil then
    cache.handlers[target] = browserProfile(profile)
    return cache.handlers[target]
  elseif string.find(target, "^/") then
    id = appID(target)
  elseif string.find(target, "%.") then
    id = target
  else
    id = appID("/Applications/" .. target .. ".app")
  end

  if id ~= nil then
    cache.handlers[target] = function(url)
      hs.application.launchOrFocusByBundleID(id)
      hs.urlevent.openURLWithBundle(url, id)
    end
  end

  if cache.handlers[target] ~= nil then
    return cache.handlers[target]
  else
    return cache.handlers._default
  end
end

-- Local functions to decode URLs
local function hex2char(x)
  return string.char(tonumber(x, 16))
end

local function unescape(url)
  return url:gsub("%%(%x%x)", hex2char)
end

local function matchApp(app, title, pattern)
  log.df("Matching app '%s' and title '%s' against pattern '%s'", app, title, pattern)
  if string.find(pattern, ":") then
    local appPattern, titlePattern = table.unpack(hs.fnutils.split(pattern, ":", 1))
    return string.find(app, appPattern) and string.find(title, titlePattern)
  else
    return string.find(app, pattern)
  end
end

local function matchApps(app, title, pattern)
  local isMatching = (pattern == nil)
    or (type(pattern) == "string" and matchApp(app, title, pattern))
    or (type(pattern) == "table" and hs.fnutils.some(pattern, hs.fnutils.partial(matchApp, app, title)))

  if isMatching then
    log.df(
      "  App pattern '%s' is nil or matches application name '%s' or title '%s' - evaluating rule.",
      pattern,
      app,
      title
    )
  else
    log.df(
      "  App pattern '%s' does not match application name '%s' or title '%s' - skipping rule.",
      pattern,
      app,
      title
    )
  end

  return isMatching
end

local function findOrLoadRulesFromFile(file, reload)
  local fullPath = hs.configdir .. "/" .. file

  if reload or not cache.ruleFiles[file] then
    log.df("Loading rules from file '%s'", file)
    cache.ruleFiles[file] = dofile(fullPath)
  end

  if not cache.ruleFileWatchers[file] and hs.fs.attributes(fullPath) then
    log.df("Creating watcher for file '%s'", file)
    cache.ruleFileWatchers[file] = hs.pathwatcher
      .new(fullPath, function(_, flags)
        -- Only trigger reloading the file when the 'itemModified' flag is present
        if hs.fnutils.some(flags, function(f)
          return f["itemModified"]
        end) then
          findOrLoadRulesFromFile(file, true)
        end
      end)
      :start()
  end

  return cache.ruleFiles[file]
end

local function matchURL(url, redirPattern, origArgs)
  if type(redirPattern) == "string" then
    redirPattern = { redirPattern }
  end

  if type(redirPattern) == "table" then
    local matchingPattern = hs.fnutils.find(redirPattern, function(pattern)
      return string.find(url, pattern)
    end)
    if matchingPattern then
      return matchingPattern
    end
  elseif type(redirPattern) == "function" then
    return redirPattern(url, table.unpack(origArgs))
  else
    log.ef("    Decoder has an unknown second value of type '%s'", type(redirPattern))
  end
end

local function decodeURL(url, origArgs, currentApp, currentAppTitle, callback, decoder, ...)
  local name, redirPattern, replacement, skipDecodeURL, sourceApp = table.unpack(decoder)

  local restOfDecoders = table.pack(...)

  log.df("  Testing decoder '%s' (%d more)", name, #restOfDecoders)

  local nextDecoderOrReturn = function(decodedURL, skipDecodeOverride)
    if decodedURL then
      log.df("    Decoded URL: '%s'", decodedURL)
      if skipDecodeOverride == false or (skipDecodeOverride == nil and not skipDecodeURL) then
        log.df("    Unescaping decoded URL '%s'", decodedURL)
        url = unescape(decodedURL)
        log.df("    Unescaped URL: '%s'", url)
      else
        url = decodedURL
      end
    end

    if #restOfDecoders > 0 then
      return decodeURL(url, origArgs, currentApp, currentAppTitle, callback, table.unpack(restOfDecoders))
    else
      return callback(url, currentApp, currentAppTitle)
    end
  end

  if matchApps(currentApp, currentAppTitle, sourceApp) then
    local matchingPattern = matchURL(url, redirPattern, origArgs)
    if matchingPattern then
      log.df("    Applying decoder '%s' to URL '%s'", name, url)
      if type(replacement) == "string" then
        return nextDecoderOrReturn(string.gsub(url, matchingPattern, replacement))
      elseif type(replacement) == "function" then
        return replacement(url, nextDecoderOrReturn, log)
      else
        log.ef("    Decoder '%s' has an unknown third value of type '%s'", name, type(replacement))
      end
    end
  end

  return nextDecoderOrReturn(url, true)
end

local function evaluateRule(rule, url, currentApp, currentAppTitle)
  local patterns, target, appPatterns = table.unpack(rule)

  -- If appPatterns is given, then first of all check whether the source app matches, otherwise we skip the whole thing
  if matchApps(currentApp, currentAppTitle, appPatterns) then
    if type(patterns) == "string" then
      patterns = { patterns }
    end

    for _, pattern in ipairs(patterns) do
      log.df("  Testing URL with pattern '%s'", pattern)
      if string.match(url, pattern) then
        local handler = findOrBuildHandler(target)
        log.df("    Match found, opening with '%s'", target)
        handler(url)
        return true
      end
    end
  end
end

local function evaluateRules(url, currentApp, currentAppTitle)
  log.df("Final URL to open: '%s'", url)

  for _, rule in ipairs(config.urls.rules) do
    if type(rule) == "string" then
      -- Load additional rules from a file
      local rules = findOrLoadRulesFromFile(rule)
      for _, fileRule in ipairs(rules) do
        log.df("Evaluating rule %s from file '%s'", hs.inspect(fileRule), rule)
        if evaluateRule(fileRule, url, currentApp, currentAppTitle) then
          return
        end
      end
    elseif type(rule) == "table" then
      log.df("Evaluating rule %s", hs.inspect(rule))
      if evaluateRule(rule, url, currentApp, currentAppTitle) then
        return
      end
    else
      log.ef("Unknown type '%s' for rule %s, must be a string or a table.", type(rule), rule)
    end
  end

  -- Fall through to the default handler
  log.df("No match found, opening with default handler")
  cache.handlers._default(url)
end

local function getAppAndTitle(senderPID)
  local currentApp = senderPID ~= nil and senderPID ~= -1 and hs.application.applicationForPID(senderPID)
    or hs.application.frontmostApplication()
  local focusedWindow = currentApp:focusedWindow()

  return currentApp:name(), focusedWindow and focusedWindow:title()
end

module.start = function()
  hs.urlevent.setDefaultHandler("http")

  cache.handlers._default = findOrBuildHandler(config.urls.defaultHandler)

  ---@diagnostic disable-next-line: duplicate-set-field
  hs.urlevent.httpCallback = function(...)
    local _, _, _, fullURL, senderPID = ...
    local callbackArgs = table.pack(...)
    log.df("httpCallback called with args %s", hs.inspect(callbackArgs))

    local currentApp, currentAppTitle = getAppAndTitle(senderPID)

    log.df("Dispatching URL '%s' from application '%s' ('%s')", fullURL, currentApp, currentAppTitle)

    decodeURL(
      fullURL,
      callbackArgs,
      currentApp,
      currentAppTitle,
      evaluateRules,
      table.unpack(config.urls.redirDecoders)
    )
  end
end

module.stop = function()
  hs.urlevent.httpCallback = nil
end

return module
