local module = {}

local log = hs.logger.new("fzf", "debug")

local FZF_PATH = "/opt/homebrew/bin/fzf"

local function buildCommand(filter, inputPath, opts)
  local command =
    string.format("%s %s --filter '%s' < '%s'", FZF_PATH, opts or "", filter:gsub("'", "'\\''"), inputPath)
  return command
end

-- filter an input with fzf
module.filter = function(filterQuery, input, lineProcessor, opts)
  local inputPath = hs.fs.temporaryDirectory() .. "fzf-input-" .. hs.host.uuid()
  local inputFile = io.open(inputPath, "w")
  if not inputFile then
    log.ef("can't open fzf input file for writing: %s", inputPath)
    return
  end

  if type(input) == "function" then
    input(inputFile)
  elseif type(input) == "string" then
    inputFile:write(input)
  else
    log.ef("wrong argument type for input: %s - accepting function or string", type(input))
    inputFile:close()
    return
  end
  inputFile:close()

  local command = buildCommand(filterQuery, inputPath, opts)
  local fzf = io.popen(command)
  if not fzf then
    log.ef("can't read output of fzf")
    os.remove(inputPath)
    return
  end

  local result

  if type(lineProcessor) == "function" then
    if opts:match("%-%-print0") then
      result = fzf:read("*a")
      for line in result:gmatch("(.-)\0") do
        lineProcessor(line)
      end
    else
      for line in fzf:lines() do
        lineProcessor(line)
      end
    end
  elseif lineProcessor == nil then
    result = fzf:read("*a")
  else
    log.ef("wrong argument type for lineProcessor: %s - must be a function", type(lineProcessor))
  end

  fzf:close()
  os.remove(inputPath)

  return result
end

return module
