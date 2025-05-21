local cache = { clicker = nil }
local module = { cache = cache, delay = 0.8 }

local log = hs.logger.new("autoclicker", "debug")

local function startClicker(button, delay)
  button = button or "leftClick"
  delay = delay or module.delay
  log.d("starting " .. button .. " clicker")
  cache.clicker = hs.timer.doEvery(delay, function()
    hs.eventtap[button](hs.mouse.absolutePosition())
  end)
end

local function stopClicker()
  if cache.clicker then
    log.d("stopping clicker")
    cache.clicker:stop()
    cache.clicker = nil
  end
end

module.toggleAutoclicker = function(button)
  if cache.clicker then
    stopClicker()
  else
    startClicker(button)
  end
end

module.start = function()
  hyper.multiBind("x", function()
    module.toggleAutoclicker("rightClick")
  end)
  hyper.multiBind("z", function()
    module.toggleAutoclicker()
  end)
end

module.stop = function()
  stopClicker()
end

return module
