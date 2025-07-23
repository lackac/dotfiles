local indicator = require("whisper.indicator")
local recording = require("whisper.recording")
local transcription = require("whisper.transcription")

local module = {}
local log = hs.logger.new("whisper", "debug")

local function cleanup()
  log.df("Cleaning up whisper module")
  indicator.hide()
  recording.cleanup()
  transcription.cleanup()
end

module.startRecording = function()
  log.df("module.startRecording() called")

  indicator.show("Recording...")

  return recording.start(function()
    -- onCancel callback
    indicator.hide()
  end)
end

module.stopRecording = function(callback)
  log.df("module.stopRecording() called")

  local audioFile = recording.stop()
  if not audioFile then
    if callback then
      callback(nil, "Not recording")
    end
    return
  end

  indicator.show("Transcribing...")

  transcription.transcribe(audioFile, function(transcript, error)
    indicator.hide()
    if callback then
      callback(transcript, error)
    end
  end)
end

module.isRecording = function()
  log.df("module.isRecording() called, returning: %s", tostring(recording.isRecording()))
  return recording.isRecording()
end

module.toggle = function(options)
  log.df("module.toggle() called with options: %s", hs.inspect(options or {}))
  options = options or {}
  local copyToClipboard = options.copyToClipboard ~= false -- default true
  local paste = options.paste or false
  local forcePaste = options.forcePaste or false
  local callback = options.callback

  if recording.isRecording() then
    -- Stop recording and transcribe
    module.stopRecording(callback or function(transcript, error)
      if error then
        hs.alert.show("Transcription error: " .. error, 3)
      elseif transcript then
        if copyToClipboard then
          hs.pasteboard.setContents(transcript)
        end

        if forcePaste then
          hs.eventtap.keyStrokes(transcript)
        elseif paste then
          hs.eventtap.keyStroke({ "cmd" }, "v")
        end
      end
    end)
  else
    -- Start recording
    if not module.startRecording() then
      hs.alert.show("Failed to start recording", 2)
    end
  end
end

module.togglePaste = function(callback)
  log.df("module.togglePaste() called")
  module.toggle({ paste = true, callback = callback })
end

module.toggleForcePaste = function(callback)
  log.df("module.toggleForcePaste() called")
  module.toggle({ forcePaste = true, copyToClipboard = false, callback = callback })
end

module.start = function()
  log.df("Whisper module started")
  return module
end

module.stop = function()
  log.df("Whisper module stopping")
  cleanup()
end

return module
