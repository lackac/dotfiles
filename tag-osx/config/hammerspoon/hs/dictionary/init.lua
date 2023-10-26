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

local function lookupFn(localDefaults)
  return function(word, options)
    options = options or {}
    for key, default in pairs(defaultOptions) do
      if options[key] == nil then
        options[key] = localDefaults[key] or default
      elseif type(options[key]) == "string" and enums[key] then
        options[key] = enums[key][options[key]]
      end
    end

    return lib.lookup(word, options.dictionary, options.format, options.matching, options.maxResults)
  end
end

module.lookup = lookupFn({ dictionary = "active" })
module.define = lookupFn({ dictionary = "defaultDictionary" })
module.synonyms = lookupFn({ dictionary = "defaultThesaurus" })

return module
