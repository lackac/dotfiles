local module = {}

module.flatten = function(t, max, result)
  result = result or {}

  hs.fnutils.each(t, function(item)
    if type(item) == "table" and (not max or max > 0) then
      module.flatten(item, max and max - 1, result)
    else
      table.insert(result, item)
    end
  end)

  return result
end

module.keys = function(t)
  local keys = {}

  for k, _ in pairs(t) do
    table.insert(keys, k)
  end

  return keys
end

module.uniq = function(t)
  local hash = {}
  local results = {}

  hs.fnutils.each(t, function(value)
    if not hash[value] then
      table.insert(results, value)
      hash[value] = true
    end
  end)

  return results
end

module.equal = function(a, b)
  if #a ~= #b then
    return false
  end

  for i, _ in ipairs(a) do
    if b[i] ~= a[i] then
      return false
    end
  end

  return true
end

return module
