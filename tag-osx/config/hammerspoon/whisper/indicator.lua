local log = hs.logger.new("whisper.indicator", "debug")

local indicator = {}

local function hideIndicator()
  if indicator.canvas then
    indicator.canvas:delete()
    indicator.canvas = nil
  end
end

local function createIndicator(text)
  log.df("Creating indicator with text: %s", text)
  hideIndicator() -- Close any existing indicator first

  local screen = hs.screen.primaryScreen()
  local frame = screen:frame()

  -- Fixed dimensions for the indicator
  local indicatorWidth = 140
  local indicatorHeight = 40

  -- Position at bottom right with padding
  local padding = 20
  local xPosition = frame.w - indicatorWidth - padding
  local yPosition = frame.h - indicatorHeight - padding

  local rect = hs.geometry.rect(xPosition, yPosition, indicatorWidth, indicatorHeight)

  indicator.canvas = hs.canvas.new(rect)

  -- Add background with rounded corners
  indicator.canvas[1] = {
    type = "rectangle",
    action = "fill",
    fillColor = { red = 0.1, green = 0.1, blue = 0.1, alpha = 0.85 },
    roundedRectRadii = { xRadius = 8, yRadius = 8 },
  }

  -- Add text with color indication
  local textColor = text == "Recording..." and { red = 1, green = 0.3, blue = 0.3, alpha = 1 }
    or { red = 0.3, green = 0.6, blue = 1, alpha = 1 }
  indicator.canvas[2] = {
    type = "text",
    text = text,
    textColor = textColor,
    textFont = "AppleSystemUIFont",
    textSize = 14,
    frame = {
      x = 10,
      y = (indicatorHeight - 20) / 2,
      w = 120,
      h = 20,
    },
  }

  indicator.canvas:show()
end

return {
  show = createIndicator,
  hide = hideIndicator,
}
