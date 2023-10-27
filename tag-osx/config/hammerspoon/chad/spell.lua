local dictionary = require("hs.dictionary")
local nerdFontsIcon = require("ext.images").nerdFontsIcon

local module = {
  keyword = "spell",
  useFzf = true,
  tip = { text = "spell⇥ to check correct spelling of word" },
}

local log

local spellCheckIcon = nerdFontsIcon("󰓆", "brown")

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))

  if #query > 1 then
    local guesses = dictionary.guesses(query)
    return hs.fnutils.map(guesses, function(guess)
      return {
        text = guess,
        id = "guess:" .. guess,
        source = module.requireName,
        image = spellCheckIcon,
      }
    end)
  else
    return {}
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
  log = hs.logger.new(module.requireName, "verbose")
end

module.stop = function() end

return module
