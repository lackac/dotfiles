local cache = {}
local module = { cache = cache, enabled = {} }

-- modifiers in use:
-- caps lock is mapped to ctrl and left ctrl to F19 with hidutil (see ~/bin/remap_keys)
-- * cltr+alt: move focus between windows
-- * ctrl+shift: do things to windows
-- * hyper (global modal): global shortcuts and app switching

module.start = function()
  hs.fnutils.each(module.enabled, function(binding)
    cache[binding] = require("bindings." .. binding)
    cache[binding].start()
  end)
end

module.stop = function()
  hs.fnutils.each(cache, function(binding)
    binding.stop()
  end)
end

return module
