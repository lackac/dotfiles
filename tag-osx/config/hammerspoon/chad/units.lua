local capture = require("ext.utils").capture
local images = require("ext.images")

local cache = {}
local module = {
  keyword = "u",
  cache = cache,
  placeholder = "1km mi / 1GBP HUF",
  tip = { text = "u⇥ for unit conversions" },
}

local log

local unitsPath = "/opt/homebrew/bin/gunits"
local unitsImage = images.nerdFontsIcon("󰯍", "chocolate")

local categories = {
  {
    name = "currency",
    units = {
      "HUF",
      "GBP",
      "EUR",
      "USD",
      "CHF",
      "DKK",
      "CZK",
      "NOK",
      "SEK",
      "PLN",
      "RON",
      "UAH",
      "RUB",
      "AED",
      "AUD",
      "CNY",
      "JPY",
      "KRW",
      "INR",
      "CAD",
      "HKD",
    },
    defaults = { "HUF", "GBP", "EUR", "USD" },
    transformQuery = string.upper,
    unitImage = images.flagIcon,
  },
}

local function findCategory(unit)
  if unit == nil or unit == "" then
    return
  end

  for _, category in ipairs(categories) do
    if category.transformQuery then
      unit = category.transformQuery(unit)
    end
    if hs.fnutils.contains(category.units, unit) then
      return category
    end
  end
end

local function evaluateExpression(expr)
  log.vf("evaluating '%s' with gunits", expr)

  local from, to = expr:match("^(.*)%s+(.*)$")
  local command

  if from then
    command = string.format("%s --terse '%s' '%s'", unitsPath, from:gsub("'", "'\\''"), to:gsub("'", "'\\''"))
  else
    command = string.format("%s --terse '%s'", unitsPath, expr:gsub("'", "'\\''"))
  end

  return capture(command):gsub("%s+$", "")
end

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))

  query = query:gsub("^ +", ""):gsub(" +$", "")

  if query:len() > 1 then
    local fromUnit = query:match("[%d. ]+([^%d ]+)")
    local toUnit = query:match("[%d. ]+[^%d ]+ +([^%d ]+)$")

    local category = findCategory(fromUnit)
    if category and category.transformQuery then
      fromUnit = category.transformQuery(fromUnit)
      query = category.transformQuery(query)
    end

    local results = {}
    if category and not toUnit then
      for i, unit in ipairs(category.defaults) do
        if unit ~= fromUnit then
          local result = evaluateExpression(query .. " " .. unit)
          log.vf("result => %s", result)
          if result then
            table.insert(results, {
              text = result .. " " .. unit,
              id = "units-result-" .. i,
              source = module.requireName,
              image = category and category.unitImage and category.unitImage(unit) or unitsImage,
            })
          end
        end
      end
    else
      local result = evaluateExpression(query)
      log.vf("result => %s", result)
      if result then
        table.insert(results, {
          text = result,
          id = "units-result",
          source = module.requireName,
          image = category and category.unitImage and category.unitImage(toUnit) or unitsImage,
        })
      end
    end

    return results
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
