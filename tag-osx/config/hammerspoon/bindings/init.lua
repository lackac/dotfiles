local cache = {}
local module = { cache = cache, enabled = {} }

-- modifiers in use:
-- * cltr+alt: move focus between windows
-- * ctrl+shift: do things to windows
-- * ultra: custom/global bindings

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
