local log = hs.logger.new("whisper.recording", "debug")

local recording = {
  task = nil,
  isRecording = false,
  currentFile = nil,
  escapeHotkey = nil,
}

local function generateTempFilename()
  local timestamp = os.time()
  return "/tmp/whisper_recording_" .. timestamp .. ".wav"
end

local function cleanup()
  log.df("Cleaning up recording")

  if recording.task then
    recording.task:terminate()
    recording.task = nil
  end

  if recording.escapeHotkey then
    recording.escapeHotkey:delete()
    recording.escapeHotkey = nil
  end

  recording.isRecording = false

  if recording.currentFile and hs.fs.attributes(recording.currentFile) then
    log.df("Removing temporary file: %s", recording.currentFile)
    os.remove(recording.currentFile)
    recording.currentFile = nil
  end
end

local function start(onCancel)
  log.df("start() called")
  if recording.isRecording then
    log.wf("Already recording, ignoring start request")
    return false
  end

  recording.currentFile = generateTempFilename()
  log.df("Starting recording to file: %s", recording.currentFile)

  recording.task = hs.task.new("/opt/homebrew/bin/ffmpeg", function(exitCode, stdOut, stdErr)
    log.df("Recording task completed with exit code: %d", exitCode)
    -- ffmpeg outputs info to stderr even on success, and various exit codes are normal when terminated
    -- Just log the completion, don't treat any exit code as error since we're terminating it manually
    log.df("Recording completed with exit code: %d", exitCode)
  end, {
    "-y",
    "-f",
    "avfoundation",
    "-i",
    ":default",
    "-ar",
    "16000",
    "-ac",
    "1",
    recording.currentFile,
  })

  if recording.task:start() then
    recording.isRecording = true
    log.df("Recording started successfully")

    -- Bind escape key to cancel recording
    recording.escapeHotkey = hs.hotkey.bind({}, "escape", function()
      log.df("Recording cancelled by user via Escape key")
      cleanup()
      if onCancel then
        onCancel()
      end
    end)

    return true
  else
    log.ef("Failed to start recording task")
    cleanup()
    return false
  end
end

local function stop()
  log.df("stop() called")
  if not recording.isRecording then
    log.wf("Not recording, ignoring stop request")
    return nil
  end

  log.df("Stopping recording")

  if recording.task then
    recording.task:terminate()
    recording.task = nil
  end

  recording.isRecording = false

  -- Clean up escape hotkey since we're proceeding to transcription
  if recording.escapeHotkey then
    recording.escapeHotkey:delete()
    recording.escapeHotkey = nil
  end

  local file = recording.currentFile
  recording.currentFile = nil -- Clear it so cleanup doesn't delete it

  return file
end

local function isRecording()
  return recording.isRecording
end

return {
  start = start,
  stop = stop,
  isRecording = isRecording,
  cleanup = cleanup,
}
