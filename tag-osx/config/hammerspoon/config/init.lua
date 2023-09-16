local module = {}

for file in hs.fs.dir(hs.configdir .. "/config") do
  local ns = string.match(file, "(.*)%.lua$")
  if ns ~= nil and ns ~= "init" then
    module[ns] = require("config." .. ns)
  end
end

return module
