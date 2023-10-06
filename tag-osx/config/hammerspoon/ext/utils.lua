local module = {}

-- capitalize string
module.capitalize = function(str)
  return str:gsub("^%l", string.upper)
end

-- run cmd and return it's output
module.capture = function(cmd)
  local handle = io.popen(cmd)
  local result = handle and handle:read("*a")

  if handle then
    handle:close()
  end

  return result
end

module.keys = function(obj)
  local keys = {}

  for k, _ in pairs(obj) do
    table.insert(keys, k)
  end

  return keys
end

-- run function without window animation
module.noAnim = function(callback)
  local lastAnimDuration = hs.window.animationDuration
  hs.window.animationDuration = 0

  callback()

  hs.window.animationDuration = lastAnimDuration
end

module.rgb = function(r, g, b, a)
  return { red = r / 255, green = g / 255, blue = b / 255, alpha = a or 1.0 }
end

module.unescape = function(str)
  local ret = string.gsub(str, "+", " ")

  ret = string.gsub(ret, "%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)

  return ret
end

return module
