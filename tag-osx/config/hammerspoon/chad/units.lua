local capture = require("ext.utils").capture
local nerdFontsIcon = require("ext.images").nerdFontsIcon

local cache = {}
local module = {
  keyword = "u",
  cache = cache,
  placeholder = "1km mi / 1GBP HUF",
  tip = { text = "u⇥ for unit conversions" },
}

local log

local unitsPath = "/opt/homebrew/bin/gunits"
local unitsImage = nerdFontsIcon("󰯍", "chocolate")

local function evaluateExpression(expr)
  log.vf("evaluating '%s' with gunits", expr)

  local from, to = expr:match("^(.*)%s+(.*)$")
  local command

  if from then
    command = string.format("%s --terse '%s' '%s'", unitsPath, from:gsub("'", "'\\''"), to:gsub("'", "'\\''"))
  else
    command = string.format("%s --terse '%s'", unitsPath, expr:gsub("'", "'\\''"))
  end

  return capture(command)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))

  if query:len() > 1 then
    local result = evaluateExpression(query)
    log.vf("result => %s", result)
    if result then
      return {
        {
          text = result,
          id = "units-result",
          source = module.requireName,
          image = unitsImage,
        },
      }
    end
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
  log = hs.logger.new(module.requireName, "debug")
end

module.stop = function() end

return module
