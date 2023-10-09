local nerdFontsIcon = require("ext.images").nerdFontsIcon

local module = {
  keyword = "ip",
  useFzf = true,
  tip = { text = "ip⇥ to list current IP addresses" },
}

local log

local iconColor = "brown"
local remoteIPIcon = nerdFontsIcon("", iconColor)
local localIPIcon = nerdFontsIcon("󱦂", iconColor)

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))

  local choices = {}

  local status, remoteIP, _ = hs.http.get("https://icanhazip.com")
  if status == 200 then
    table.insert(choices, {
      text = remoteIP:gsub("%s+", ""),
      subText = "Remote IP",
      fzfInput = "Remote",
      id = "ip-remote",
      source = module.requireName,
      image = remoteIPIcon,
    })
  end

  local interfaces = hs.network.interfaces()
  for _, interface in ipairs(interfaces) do
    if interface:match("^en%d+") then
      local details = hs.network.interfaceDetails(interface)
      local active = details and details.Link and details.Link.Active

      if active then
        local name = hs.network.interfaceName(interface)
        local ssid = details.AirPort and details.AirPort.SSID

        local buildChoice = function(ipv, ip, i)
          local sub = interface .. " " .. ipv .. (name and " (" .. name .. (ssid and " " .. ssid or "") .. ")" or "")
          table.insert(choices, {
            text = ip,
            subText = sub,
            fzfInput = sub,
            id = "ip-" .. interface .. "-" .. ipv .. "-" .. i,
            source = module.requireName,
            image = localIPIcon,
          })
        end

        local ipv4Addresses = details.IPv4 and details.IPv4.Addresses or {}
        for i, ip in ipairs(ipv4Addresses) do
          buildChoice("IPv4", ip, i)
        end

        local ipv6Addresses = details.IPv6 and details.IPv6.Addresses or {}
        for i, ip in ipairs(ipv6Addresses) do
          buildChoice("IPv6", ip, i)
        end
      end
    end
  end

  return choices
end

module.complete = function(choice)
  log.v("complete choice: " .. hs.inspect(choice))
  if choice then
    hs.pasteboard.setContents(choice.text)
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "debug")
end

module.stop = function() end

return module
