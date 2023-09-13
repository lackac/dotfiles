hyper = hs.hotkey.modal.new({}, "F15")

local log = hs.logger.new("hyper", "debug")

hyper.pressed = function()
  hyper:enter()
end

hyper.entered = function()
  log.d("ON")
end

hyper.released = function()
  hyper:exit()
end

hyper.exited = function()
  log.d("OFF")
end

hyper.start = function()
  hs.hotkey.bind({}, "F19", hyper.pressed, hyper.released)

  hyper:bind({}, "escape", hyper.released)
end

hyper.stop = function() end

return hyper
