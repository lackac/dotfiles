local capture = require("ext.utils").capture

local cache = {}
local module = {
  autoActivate = "=",
  cache = cache,
  placeholder = "enter mathematical expression",
  tip = { text = "type = for complex mathematical expressions" },
}

local log

local function evaluateExpression(expr)
  log.vf("evaluating '%s' with bc", expr)
  local command = "/usr/bin/bc -l -e '" .. expr:gsub("'", "'\\''") .. "'"
  return capture(command)
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query), hs.inspect({ module.main.activeKeyword, module.autoActivate }))
  -- only evaluate simple expressions if the plugin is not fully activated
  if module.main.activeKeyword == module.autoActivate or query and query:match("^[%d%.%+%-%*/%^ %(%)]+$") then
    local result = evaluateExpression(query)
    log.vf("result => %s", result)
    if result then
      return {
        {
          text = result,
          id = "calculator-result",
          source = module.requireName,
          image = hs.image.imageFromAppBundle("com.apple.Calculator"),
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
  log = hs.logger.new(module.requireName, "verbose")
end

module.stop = function() end

return module
