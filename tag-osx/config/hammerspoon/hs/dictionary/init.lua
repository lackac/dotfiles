local lib = require("hs.libdictionary")

local module = {}

module.dictionaries = lib.dictionaries
module.activeDictionaries = lib.activeDictionaries

local versions = {
  html = 0,
  htmlWithAppCSS = 1,
  htmlWithPopoverCSS = 2,
  text = 3,
}

local function lookupFn(defaultDictionary)
  return function(word, dictionary, version)
    if type(dictionary) == "number" then
      local temp = version
      version = dictionary
      dictionary = temp
    elseif versions[dictionary] then
      local temp = version
      version = versions[dictionary]
      dictionary = temp
    end
    if dictionary == nil then
      dictionary = defaultDictionary
    end
    if versions[version] then
      version = versions[version]
    elseif version == nil then
      version = 3
    end
    return lib.lookup(word, dictionary, version)
  end
end

module.lookup = lookupFn("active")
module.define = lookupFn("defaultDictionary")
module.synonyms = lookupFn("defaultThesaurus")

return module
