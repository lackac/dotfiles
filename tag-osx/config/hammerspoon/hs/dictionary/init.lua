local lib = require("hs.libdictionary")

local module = setmetatable({}, {
  __index = function(_, key)
    return lib[key]
  end,
})

local enums = {
  matching = {
    exact = 0,
    prefix = 1,
    commonPrefix = 2,
    wildcard = 3,
  },
  format = {
    html = 0,
    htmlForApp = 1,
    htmlForPanel = 2,
    text = 3,
  },
}

local defaultOptions = {
  matching = 1,
  format = 3,
  dictionary = "active",
  maxResults = 50,
}

local dictionaryDefaults = { "all", "active", "defaultDictionary", "defaultThesaurus" }

local function lookupFn(localDefaults)
  return function(word, options)
    options = options or {}

    -- shortcut for only specifying the dictionary or one of the option keywords
    if type(options) == "string" then
      if enums.matching[options] then
        options = { matching = enums.matching[options] }
      elseif enums.format[options] then
        options = { format = enums.format[options] }
      else
        options = { dictionary = options }
      end
    end

    for key, default in pairs(defaultOptions) do
      if options[key] == nil then
        options[key] = localDefaults[key] or default
      elseif type(options[key]) == "string" and enums[key] then
        options[key] = enums[key][options[key]]
      end
    end

    -- adding the dictionary id prefix if we think it should be there
    if
      not hs.fnutils.contains(dictionaryDefaults, options.dictionary)
      and options.dictionary:match("^[a-zA-Z0-9._-]+$")
      and not options.dictionary:match("^com%.apple%.")
    then
      options.dictionary = "com.apple.dictionary." .. options.dictionary
    end

    return lib.lookup(word, options.dictionary, options.format, options.matching, options.maxResults)
  end
end

module.lookup = lookupFn({ dictionary = "active" })
module.define = lookupFn({ dictionary = "defaultDictionary" })
module.synonyms = lookupFn({ dictionary = "defaultThesaurus" })

return module
