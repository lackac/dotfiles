-- global stuff
require("console")
require("overrides")

-- global config
config = {
  apps = {
    terms = { "kitty", "Terminal" },
    browsers = { "Brave Browser", "Safari", "Google Chrome" },
  },

  urls = {
    defaultBrowser = "Brave Browser",
    defaultHandler = "profile:Default",
    rules = {
      { "https://teams%.microsoft%.com/", "Microsoft Teams" },
      "urls/client1.lua",
      "urls/client2.lua",
      "urls/100s.lua",
      "urls/slack.lua",
    },
    shorteners = {
      "adf.ly",
      "bit.do",
      "bit.ly",
      "buff.ly",
      "deck.ly",
      "fur.ly",
      "goo.gl",
      "is.gd",
      "mcaf.ee",
      "ow.ly",
      "spoti.fi",
      "su.pr",
      "t.co",
      "tiny.cc",
      "tinyurl.com",
      "urlshortener.teams.microsoft.com",
    },
    redirDecoders = {
      {
        "Slack",
        "https://slack%.com/openid/connect/login_initiate_redirect",
        function(url, callback, log)
          hs.http.doAsyncRequest(url, "GET", nil, {}, function(status, _, headers)
            log.df("    Slack decoder response status: %d, location: %s", status, hs.inspect(headers.Location))
            if status >= 300 and status < 400 then
              callback(headers.Location, true)
            else
              callback(url, true)
            end
          end, "protocolCachePolicy", false)
        end,
      },
      {
        "URL shorteners",
        function(_, _, host)
          return hs.fnutils.contains(config.urls.shorteners, host)
        end,
        function(url, callback, log)
          hs.http.doAsyncRequest(url, "GET", nil, {}, function(status, _, headers)
            log.df("    URL shortener response status: %d, location: %s", status, hs.inspect(headers.Location))
            if status >= 300 and status < 400 then
              callback(headers.Location, true)
            else
              callback(url, true)
            end
          end, "protocolCachePolicy", false)
        end,
      },
      { "awstrack.me links", "https://.*%.awstrack%.me/.-/(.*)", "%1" },
    },
  },

  wm = {
    -- tilingMethod = "grid",
    tilingMethod = "autogrid",
    displayOrder = {
      "Built-in Retina Display",
      "LG SDQHD",
      "LF32TU87",
    },
  },

  window = {
    highlightBorder = true,
    highlightMouse = true,
    historyLimit = 100,
    borderStyle = {
      width = 4,
      alpha = 0.6,
      distance = 4,
      roundRadius = 12,
    },
  },

  network = {
    home = "Hovirag",
    inlaws = "Kaktusz",
    office = "Unifi",
  },
}

local bindings = require("bindings")
local modules = {
  bindings,
  require("urls"),
  require("mod.app_logger"),
  require("mod.theme"),
  require("mod.autoborder"),
  require("mod.watchables"),
}

bindings.enabled = {
  "focus",
  "global",
}
if config.wm.tilingMethod == "autogrid" then
  table.insert(bindings.enabled, "grid")
  table.insert(modules, require("mod.autogrid"))
else
  table.insert(bindings.enabled, config.wm.tilingMethod)
end

-- start/stop modules
hs.fnutils.each(modules, function(module)
  if module then
    module.start()
  end
end)

---@diagnostic disable-next-line: duplicate-set-field
hs.shutdownCallback = function()
  hs.fnutils.each(modules, function(module)
    if module then
      module.stop()
    end
  end)
end

-- notify when ready
hs.notify.new({ title = "Hammerspoon", subTitle = "Ready" }):send()
