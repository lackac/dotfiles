local module = {}

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

-- run cmd and return it's output
module.capture = function(cmd)
  local handle = io.popen(cmd)
  local result = handle and handle:read("*a")

  if handle then
    handle:close()
  end

  return result
end

-- capitalize string
module.capitalize = function(str)
  return str:gsub("^%l", string.upper)
end

module.unescape = function(str)
  local ret = string.gsub(str, "+", " ")

  ret = string.gsub(ret, "%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)

  return ret
end

module.debounce = function(func, wait, immediate)
  local timeout = nil

  return function()
    local later = function()
      timeout = nil

      if not immediate then
        func()
      end
    end

    local callNow = immediate and not timeout

    if timeout then
      timeout:stop()
    end

    timeout = hs.timer.doAfter(wait, later)

    if callNow then
      func()
    end
  end
end

module.assetPath = function(file)
  return hs.configdir .. "/assets/" .. file
end

module.rgb = function(r, g, b, a)
  return { red = r / 255, green = g / 255, blue = b / 255, alpha = a or 1.0 }
end

return module
