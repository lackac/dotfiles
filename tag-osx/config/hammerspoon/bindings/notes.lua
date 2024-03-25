local windowMetadata = require("ext.window").windowMetadata

local module = {}

local log = hs.logger.new("notes", "debug")

local runtimeDir = os.getenv("XDG_RUNTIME_DIR") or os.getenv("HOME") .. "/Library/Caches/TemporaryItems/runtime"
local kittyPath = "/opt/homebrew/bin/kitty"
local zshPath = "/opt/homebrew/bin/zsh"

local function kitty(command, input, options)
  options = options or {}

  local kittySocket
  for file in hs.fs.dir(runtimeDir) do
    if file:match("^kitty%-%d+$") then
      kittySocket = runtimeDir .. "/" .. file
    end
  end

  if not kittySocket then
    log.warn("Couldn't find a running kitty instance")
    return
  end

  local kittyArgs =
    { "@", "--to", "unix:" .. kittySocket, "launch", "--no-response", "--type", "os-window", "--copy-colors" }

  if options.title then
    hs.fnutils.concat(kittyArgs, { "--os-window-title", options.title })
  end

  if input then
    local inputPath = hs.fs.temporaryDirectory() .. "kitty-input-" .. hs.host.uuid()
    local inputFile = io.open(inputPath, "w")
    if not inputFile then
      log.ef("can't open kitty input file for writing: %s", inputPath)
      return
    end

    if type(input) == "function" then
      if debug.getinfo(input).nparams == 0 then
        inputFile:write(input())
      else
        input(inputFile)
      end
    elseif type(input) == "string" then
      inputFile:write(input)
    else
      log.ef("wrong argument type for input: %s - accepting function or string", type(input))
      inputFile:close()
      return
    end
    inputFile:close()

    if command:match("{}") then
      command = command:gsub("{}", '"' .. inputPath .. '"')
    else
      command = command .. ' <"' .. inputPath .. '"'
    end
  end

  hs.fnutils.concat(kittyArgs, { "--", zshPath, "-i", "-c", command })

  log.df("running kitty with args: %s", hs.inspect(kittyArgs))
  local task = hs.task.new(kittyPath, function(code, out, err)
    if code ~= nil then
      log.ef("kitty exit code: %s - %s", code, err)
    end
    log.df("kitty output: %s", out)
  end, kittyArgs)

  task:start()
end

-- / , 0 1 2 3 4 5 6 7 8 9 C F G L M P Q R S T U V
module.start = function()
  hs.fnutils.each({
    { key = "n", command = "cd $ZK_NOTEBOOK_DIR && zk edit --interactive" },
    -- { key = "d", command = 'cd $ZK_NOTEBOOK_DIR && nvim "$(zk new -g daily --no-input --print-path 2>>/tmp/zk.err)"' },
    {
      key = "b",
      command = 'cd $ZK_NOTEBOOK_DIR && nvim "$(zk new -g bookmark --interactive --print-path 2>>/tmp/zk.err <{})"',
      input = function()
        local win = hs.window.frontmostWindow()
        local _, meta = windowMetadata(win)
        log.df("input for bookmark: %s", meta)
        return meta or ""
      end,
    },
  }, function(object)
    hyper.multiBind(object.key, function()
      kitty(object.command, object.input, { title = "zk notes" })
    end)
  end)
end

module.stop = function() end

return module
