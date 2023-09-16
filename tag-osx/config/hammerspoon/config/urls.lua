return {
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
        return hs.fnutils.contains(require("config.urls").shorteners, host)
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
}
