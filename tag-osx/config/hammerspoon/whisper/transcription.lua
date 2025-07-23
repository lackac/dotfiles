local log = hs.logger.new("whisper.transcription", "debug")

local transcription = {
  task = nil,
}

local function cleanup()
  log.df("Cleaning up transcription")

  if transcription.task then
    transcription.task:terminate()
    transcription.task = nil
  end
end

local function transcribe(audioFile, callback)
  log.df("transcribe() called with file: %s", audioFile)

  if not audioFile or not hs.fs.attributes(audioFile) then
    log.ef("Audio file does not exist: %s", audioFile or "nil")
    if callback then
      callback(nil, "Audio file not found")
    end
    return
  end

  hs.timer.waitUntil(function()
    return audioFile and hs.fs.attributes(audioFile) ~= nil
  end, function()
    log.df("Audio file ready, starting transcription")

    transcription.task = hs.task.new(
      os.getenv("HOME") .. "/Code/mustafaaljadery/lightning-whisper-mlx/transcribe.sh",
      function(exitCode, stdOut, stdErr)
        log.df("Transcription task completed with exit code: %d", exitCode)

        if exitCode == 0 and stdOut then
          local transcript = stdOut:gsub("^%s*(.-)%s*$", "%1")
          log.df("Transcription successful: %s", transcript)

          -- Clean up the audio file
          if audioFile and hs.fs.attributes(audioFile) then
            os.remove(audioFile)
          end

          if callback then
            callback(transcript, nil)
          end
        else
          log.ef("Transcription failed: %s", stdErr or "unknown error")
          -- Clean up the audio file even on failure
          if audioFile and hs.fs.attributes(audioFile) then
            os.remove(audioFile)
          end
          if callback then
            callback(nil, stdErr or "Transcription failed")
          end
        end

        transcription.task = nil
      end,
      { audioFile }
    )

    if not transcription.task:start() then
      log.ef("Failed to start transcription task")
      if callback then
        callback(nil, "Failed to start transcription")
      end
    end
  end, 5.0)
end

return {
  transcribe = transcribe,
  cleanup = cleanup,
}
