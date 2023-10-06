local emojiIcon = require("ext.images").emojiIcon
local trimForDisplay = require("ext.utils").trimForDisplay
local hash = hs.hash.MD5

local cache = { translations = {}, flags = {}, languageChoices = {} }
local module = {
  keyword = "tr",
  useFzf = false,
  cache = cache,
  placeholder = "ja:en 今日は",
  tip = { text = "tr⇥ to translate text" },
}

local log

local defaultLanguages = {
  { language = "HU", name = "Hungarian" },
  { language = "EN-GB", name = "English (British)" },
  { language = "DE", name = "German" },
  { language = "ES", name = "Spanish" },
  { language = "JA", name = "Japanese" },
}
local flagExceptions = {
  CS = "CZ",
  DA = "DK",
  EL = "GR",
  ["EN-GB"] = "GB",
  ["EN-US"] = "US",
  JA = "JP",
  KO = "KR",
  NB = "NO",
  ["PT-BR"] = "BR",
  ["PT-PT"] = "PT",
  UK = "UA",
  ZH = "CH",
}
local targetLanguageCodes = {}

local deepLAPIBase = "https://api-free.deepl.com/v2/"

local function deepLRequest(method, path, data, callback)
  local headers = {
    Authorization = "DeepL-Auth-Key " .. cache.authKey,
  }

  if type(data) == "function" then
    callback = data
    data = nil
  elseif type(data) == "table" then
    data = hs.json.encode(data)
    headers["Content-Type"] = "application/json"
  end

  hs.http.doAsyncRequest(deepLAPIBase .. path, method, data, headers, callback)
end

local function flagImage(code)
  code = string.upper(code)

  if not cache.flags[code] then
    local a, b = string.byte(code, 1, 2)
    -- see https://en.wikipedia.org/wiki/Regional_indicator_symbol
    local flagCode = utf8.char(a + 0x1F1E6 - 65, b + 0x1F1E6 - 65)
    cache.flags[code] = emojiIcon(flagCode)
  end

  return cache.flags[code]
end

local function generateLanguageChoices()
  cache.languageChoices = {}

  local addLanguageChoice = function(lang)
    local target = lang.language
    local name = lang.name
    if targetLanguageCodes[target] then
      return
    end
    local flagCode = flagExceptions[target] or target
    targetLanguageCodes[target] = {
      text = "Translate into " .. name,
      target = target,
      valid = false,
      id = "translate-into-" .. target,
      source = module.requireName,
      image = flagImage(flagCode),
    }
    table.insert(cache.languageChoices, targetLanguageCodes[target])
  end

  for _, lang in ipairs(defaultLanguages) do
    addLanguageChoice(lang)
  end

  local languageTargetsCacheKey = module.requireName .. ":languageTargets"
  local cachedLanguageTargets = hs.settings.get(languageTargetsCacheKey)

  if cachedLanguageTargets then
    for _, lang in ipairs(cachedLanguageTargets) do
      addLanguageChoice(lang)
    end
  else
    deepLRequest("GET", "languages?type=target", function(code, body, headers)
      if code == 200 then
        log.v("language targets", hs.inspect({ code, body, headers }))
        local languageTargets = hs.json.decode(body)
        if languageTargets then
          hs.settings.set(languageTargetsCacheKey, languageTargets)
          for _, lang in ipairs(languageTargets) do
            addLanguageChoice(lang)
          end
        else
          log.w("couldn't parse target languages", hs.inspect({ code, body, headers }))
        end
      else
        log.w("couldn't fetch possible target languages", hs.inspect({ code, body, headers }))
      end
    end)
  end
end

local function parseQuery(query)
  local patterns = {
    { "^%s*(%a%a):(%a%a)%s+(.*)$", 1, 2, 3 },
    { "^%s*(%a%a):(%a%a%-%a%a)%s+(.*)$", 1, 2, 3 },
    { "^(.*)%s+(%a%a):(%a%a)%s*$", 2, 3, 1 },
    { "^(.*)%s+(%a%a):(%a%a%-%a%a)%s*$", 2, 3, 1 },
    { "^%s*:(%a%a)%s+(.*)$", 3, 1, 2 },
    { "^%s*:(%a%a%-%a%a)%s+(.*)$", 3, 1, 2 },
    { "^(.*)%s+:(%a%a)%s*$", 3, 2, 1 },
    { "^(.*)%s+:(%a%a%-%a%a)%s*$", 3, 2, 1 },
  }
  for _, recipe in ipairs(patterns) do
    local match = table.pack(query:match(recipe[1]))
    if #match > 0 then
      local source = match[recipe[2]] and match[recipe[2]]:upper()
      local target = match[recipe[3]] and match[recipe[3]]:upper()
      local text = match[recipe[4]]
      if target == "EN" then
        target = "EN-US"
      end
      if target == "PT" then
        target = "PT-BR"
      end
      if targetLanguageCodes[target] then
        return source, target, text
      end
    end
  end
end

local translationsCacheMaxAge = 30

local function loadTranslationsCache()
  cache.translations = hs.settings.get(module.requireName .. ":translations") or {}
end

local function saveTranslationsCache()
  -- remove translations older than max age
  local now = os.time()
  for key, translation in pairs(cache.translations) do
    if os.difftime(now, translation.t) > translationsCacheMaxAge then
      cache.translations[key] = nil
    end
  end

  hs.settings.set(module.requireName .. ":translations", cache.translations)
end

local function getTranslationFromCache(source, target, text)
  local key = hash(hs.inspect({ source, target, text }))
  if cache.translations[key] then
    cache.translations[key].t = os.time() -- refresh the key in the cache
    return cache.translations[key].results
  end
end

local function saveTranslationToCache(source, target, text, results)
  if results and #results > 0 then
    local key = hash(hs.inspect({ source, target, text }))
    cache.translations[key] = { results = results, t = os.time() }
  end
end

local function translateText(source, target, text)
  local cachedResults = getTranslationFromCache(source, target, text)
  if cachedResults then
    log.v("returning cached results", hs.inspect({ source, target, text }))
    cache.translation.results = cachedResults
    module.main.saveQuery()
    module.main.chooser:refreshChoicesCallback()
    return
  end

  log.v("translating text", hs.inspect({ source, target, text }))
  deepLRequest("POST", "translate", {
    text = { text },
    source_lang = source,
    target_lang = target,
  }, function(code, body, headers)
    if code == 200 then
      log.v("translation response", hs.inspect({ code, body, headers }))
      local response = hs.json.decode(body)
      if response then
        cache.translation.results = response.translations
        saveTranslationToCache(source, target, text, response.translations)
        module.main.saveQuery()
      else
        cache.translation.error = "couldn't parse translation response"
      end
    else
      cache.translation.error = "couldn't translate text"
    end

    if cache.translation.error then
      log.w(cache.translation.error, hs.inspect({ code, body, headers }))
    end
    module.main.chooser:refreshChoicesCallback()
  end)
end

module.compileChoices = function(query)
  log.v("compileChoices", hs.inspect(query))

  if cache.translation and cache.translation.query == query then
    local languageChoice = targetLanguageCodes[cache.translation.target]
    local choice = {
      id = "translation",
      source = module.requireName,
      image = languageChoice.image,
    }

    if cache.translation.results then
      local translations = {}
      for i, result in ipairs(cache.translation.results) do
        local text, fullText = trimForDisplay(result.text)
        local detectedSource = result.detected_source_language
        table.insert(translations, {
          text = text,
          fullText = fullText,
          subText = detectedSource and ("Detected source language: " .. detectedSource),
          id = "translation-" .. i,
          source = module.requireName,
          image = languageChoice.image,
        })
      end

      return hs.fnutils.concat(
        translations,
        hs.fnutils.ifilter(cache.languageChoices, function(lc)
          return lc.target ~= languageChoice.target
        end)
      )
    elseif cache.translation.error then
      choice.text = "Translation error: " .. cache.translation.error
      choice.error = true
      choice.valid = false
    else
      choice.text = languageChoice.text:gsub("Translate into", "Translating text into") .. "…"
      choice.valid = false
    end

    return { choice }
  end

  if query:len() > 3 then
    local _, target, _ = parseQuery(query)
    if target then
      return { targetLanguageCodes[target] }
    end
  end

  return cache.languageChoices
end

module.complete = function(choice)
  log.v("complete choice", hs.inspect(choice))
  if choice then
    hs.pasteboard.setContents(choice.fullText or choice.text)
  end
end

module.invalid = function(choice)
  log.v("invalid choice", hs.inspect(choice))

  if choice.target then
    local query = module.main.chooser:query()
    local source, _, text = parseQuery(query)
    local target = choice.target
    text = text or query
    if text == "" or text:match("^%s*$") then
      if module.main.currentSelection then
        text = module.main.currentSelection
      else
        return
      end
    end

    cache.translation = {
      query = query,
      source = source,
      target = target,
      text = text,
    }
    module.main.chooser:refreshChoicesCallback()

    translateText(source, target, text)
  elseif choice.error and cache.translation then
    -- retry translation
    cache.error = nil
    module.main.chooser:refreshChoicesCallback()
    translateText(cache.translation.source, cache.translation.target, cache.translation.text)
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "verbose")
  cache.authKey = hs.settings.get("private.deep_l_auth_key")
  loadTranslationsCache()
  generateLanguageChoices()
end

module.stop = function()
  saveTranslationsCache()
end

return module
