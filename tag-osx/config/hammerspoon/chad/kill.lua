local capture = require("ext.utils").capture
local nerdFontsIcon = require("ext.images").nerdFontsIcon

local module = {
  keyword = "kill",
  useFzf = true,
  placeholder = "search for a process to be killed",
  tip = { text = "kill⇥ to terminate a running process" },
}

local log

local iconColor = "brown"
local defaultImage = nerdFontsIcon("", iconColor)
local commonImages = {
  nvim = nerdFontsIcon("", iconColor),
  tmux = nerdFontsIcon("", iconColor),
  ruby = nerdFontsIcon("", iconColor),
}

module.compileChoices = function(query)
  log.v("compileChoices " .. hs.inspect(query))

  local choices = {}

  local processes = capture("ps -x -r -o pid,ppid,%cpu,rss,comm")
  local appsByPID = hs.fnutils.reduce(hs.application.runningApplications(), function(acc, app)
    acc[app:pid()] = app
    return acc
  end, {})

  for pid, ppid, cpu, rss, comm in processes:gmatch("\n *(%d+) +(%d+) +([%d.]+) +(%d+) +([^\n]*)") do
    pid = tonumber(pid)
    ppid = tonumber(ppid)
    cpu = tonumber(cpu)
    rss = tonumber(rss)
    if rss > 1024 * 1024 then
      rss = string.format("%.2f GiB", rss / 1024 / 1024)
    elseif rss > 1024 then
      rss = string.format("%.2f MiB", rss / 1024)
    else
      rss = rss .. " KiB"
    end

    local app = appsByPID[pid] or appsByPID[ppid]
    local basename = comm:match("([^/]*)$")
    local choice = {
      text = basename,
      subText = string.format("%.1f%% CPU, %s RAM @ %s", cpu, rss, comm),
      pid = pid,
      app = app,
      id = "process-" .. pid,
      source = module.requireName,
      image = app and app:bundleID() and hs.image.imageFromAppBundle(app:bundleID())
        or commonImages[basename]
        or defaultImage,
    }

    table.insert(choices, choice)
  end

  return choices
end

module.complete = function(choice)
  log.v("complete choice: ", hs.inspect(choice))
  local modifiers = hs.eventtap.checkKeyboardModifiers()
  if choice then
    if choice.app then
      if modifiers.ctrl then
        log.df("Force quitting application %s", choice.app:name())
        choice.app:kill9()
      else
        log.df("Quitting application %s", choice.app:name())
        choice.app:kill()
      end
    elseif choice.pid then
      local signal = modifiers.ctrl and "KILL" or "TERM"
      log.df("Sending '%s' signal to pid %d (%s)", signal, choice.pid, choice.text)
      os.execute(string.format("kill -s %s %d", signal, choice.pid))
    end
  end
end

module.start = function(main, _)
  module.main = main
  log = hs.logger.new(module.requireName, "debug")
end

module.stop = function() end

return module
