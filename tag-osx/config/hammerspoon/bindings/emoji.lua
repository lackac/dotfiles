emojiModal = hs.hotkey.modal.new()

local log = hs.logger.new("emoji", "debug")

emojiModal.pressed = function()
  emojiModal:enter()
end

emojiModal.entered = function()
  log.d("ON")
end

emojiModal.released = function()
  emojiModal:exit()
end

emojiModal.exited = function()
  log.d("OFF")
end

local function taggedPayload(text)
  return {
    ["public.utf8-plain-text"] = text,
    ["org.nspasteboard.TransientType"] = "1",
  }
end

local function pasteEmoji(text)
  local previous = hs.pasteboard.readAllData() -- full snapshot
  hs.pasteboard.writeAllData(taggedPayload(text))
  hs.eventtap.keyStroke({ "cmd" }, "v", 0)

  hs.timer.doAfter(0.08, function()
    if previous and next(previous) then
      local restore = previous
      restore["org.nspasteboard.TransientType"] = "1"
      hs.pasteboard.writeAllData(restore)
    else
      hs.pasteboard.clearContents()
    end
  end)
end

local map = {
  b = "🧠", l = "❤️", d = "😄", w = "🤷", z = "😴",
  n = "💡", r = "🚀", t = "🤔", s = "✨", g = "😎",
  q = "😀", x = "😅", m = "🙂", c = "😭", v = "😉",

  ["0"] = "🤖", f = "🔥", o = "👀", u = "🤝", j = "😂",
  y = "👍", h = "✅", a = "👎", e = "❌", i = "🙏",
  k = "👏", p = "🙌", ["'"] = "🎉", [","] = "💯", ["."] = "🤣",
}

emojiModal.start = function()
  hs.hotkey.bind({}, "F12", emojiModal.pressed, emojiModal.released)
  hs.hotkey.bind({}, "F13", emojiModal.pressed, emojiModal.released)

  for key, emoji in pairs(map) do
    local e = emoji
    emojiModal:bind({}, key, function() pasteEmoji(e) end)
  end

  emojiModal:bind({}, "escape", emojiModal.released)
end

emojiModal.stop = function() end

return emojiModal
