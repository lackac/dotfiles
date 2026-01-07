local windowMetadata = require("ext.window").windowMetadata

hs.console.toolbar(nil)
hs.console.consoleFont("FiraCode Nerd Font")

CH = {}

CH.dumpWindows = function()
  local windowList = {}

  hs.fnutils.each(hs.window.allWindows(), function(win)
    local title, meta = windowMetadata(win)
    local app = win:application()
    local axWin = hs.axuielement.windowElement(win)

    table.insert(windowList, {
      id = win:id(),
      appName = app:name(),
      bundleId = app:bundleID(),
      role = win:role(),
      subrole = win:subrole(),
      frame = win:frame().string,
      buttonZoom = axWin:attributeValue("AXZoomButton") and "exists" or "doesn't exist",
      buttonFullScreen = axWin:attributeValue("AXFullScreenButton") and "exists" or "doesn't exist",
      isResizable = axWin:isAttributeSettable("AXSize"),
      title = title,
      meta = meta,
    })
  end)

  print(hs.inspect(windowList))
end

CH.dumpScreens = function()
  hs.fnutils.each(hs.screen.allScreens(), function(s)
    print(s:id(), s:position(), s:frame(), s:name())
  end)
end

CH.timestamp = function(date)
  date = date or hs.timer.secondsSinceEpoch()
  return os.date("%F %T" .. ((tostring(date):match("(%.%d+)$")) or ""), math.floor(date))
end

CH.listAllAvailableKeys = function()
  print("=== ALL AVAILABLE KEYS ===")
  local keys = {}

  -- Collect all string keys (ignore numeric keycodes)
  for k, v in pairs(hs.keycodes.map) do
    if type(k) == "string" then
      table.insert(keys, k)
    end
  end

  -- Sort alphabetically
  table.sort(keys)

  -- Print in columns for better readability
  local columns = 4
  local count = 0
  for _, key in ipairs(keys) do
    io.write(string.format("%-15s", key))
    count = count + 1
    if count % columns == 0 then
      print()
    end
  end
  if count % columns ~= 0 then
    print()
  end

  print(string.format("\nTotal available keys: %d", #keys))
end

CH.listActiveHotkeys = function()
  print("\n=== CURRENTLY ACTIVE HOTKEYS ===")

  -- Get all active hotkeys (enabled and not shadowed)
  local hotkeys = hs.hotkey.getHotkeys()

  if #hotkeys == 0 then
    print("No active hotkeys found")
    return
  end

  -- Sort hotkeys by keyboard combination
  table.sort(hotkeys, function(a, b)
    return (a.idx or "") < (b.idx or "")
  end)

  print(string.format("%-25s %s", "KEYBOARD COMBINATION", "MESSAGE"))
  print(string.rep("-", 70))

  for _, hotkey in ipairs(hotkeys) do
    local combination = hotkey.idx or "unknown"
    local message = hotkey.msg or ""

    print(string.format("%-25s %s", combination, message))
  end

  print(string.format("\nTotal active hotkeys: %d", #hotkeys))
end

CH.listSystemAssignedKeys = function()
  print("\n=== SYSTEM-ASSIGNED HOTKEYS (POTENTIAL CONFLICTS) ===")

  local modifierCombos = {
    {},
    { "cmd" },
    { "alt" },
    { "ctrl" },
    { "shift" },
    { "cmd", "alt" },
    { "cmd", "ctrl" },
    { "cmd", "shift" },
    { "alt", "ctrl" },
    { "alt", "shift" },
    { "ctrl", "shift" },
    { "cmd", "alt", "ctrl" },
    { "cmd", "alt", "shift" },
    { "cmd", "ctrl", "shift" },
    { "alt", "ctrl", "shift" },
    { "cmd", "alt", "ctrl", "shift" },
  }

  local commonKeys = {
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    "space",
    "return",
    "tab",
    "delete",
    "escape",
  }

  local systemAssigned = {}

  -- Check common key combinations
  for _, mods in ipairs(modifierCombos) do
    for _, key in ipairs(commonKeys) do
      local assigned = hs.hotkey.systemAssigned(mods, key)
      if assigned then
        table.insert(systemAssigned, {
          mods = mods,
          key = key,
          enabled = assigned.enabled,
        })
      end
    end
  end

  if #systemAssigned == 0 then
    print("No system-assigned hotkeys found in common combinations")
    return
  end

  print(string.format("%-25s %-10s %s", "MODIFIERS", "KEY", "ENABLED"))
  print(string.rep("-", 50))

  for _, item in ipairs(systemAssigned) do
    local mods = #item.mods > 0 and table.concat(item.mods, "+") or "none"
    local enabled = item.enabled and "yes" or "no"
    print(string.format("%-25s %-10s %s", mods, item.key, enabled))
  end

  print(string.format("\nTotal system-assigned: %d", #systemAssigned))
end

CH.analyzeKeyboardSetup = function()
  print("=== HAMMERSPOON KEYBOARD SETUP ANALYSIS ===")
  print("Current keyboard layout: " .. (hs.keycodes.currentLayout() or "unknown"))
  print("Analysis date: " .. os.date())
  print("\n" .. string.rep("=", 60))

  CH.listAllAvailableKeys()
  CH.listActiveHotkeys()
  CH.listSystemAssignedKeys()

  print("\n" .. string.rep("=", 60))
  print("Analysis complete!")
end

CH.detectRadius = function()
  local axuielement = require("hs.axuielement")

  for _, win in ipairs(hs.window.allWindows()) do
    local app = win:application()
    local title = win:title() or "(no title)"
    local bundleID = app and app:bundleID() or "unknown"
    local appName = app and app:name() or "unknown"

    print("================================================================================")
    print("App: " .. appName .. " (" .. bundleID .. ")")
    print("Title: " .. title)

    local axWin = axuielement.windowElement(win)
    if axWin then
      local subrole = axWin:attributeValue("AXSubrole") or "nil"
      print("AXSubrole: " .. subrole)

      -- Check for toolbar
      local hasToolbar = false
      local toolbarItemCount = 0

      -- Check for title bar UI elements
      local hasTitleBarUI = false
      local titleBarChildren = {}

      -- Check for various title-related attributes
      local titleUIElement = axWin:attributeValue("AXTitleUIElement")
      print("AXTitleUIElement: " .. (titleUIElement and "present" or "nil"))

      local children = axWin:attributeValue("AXChildren") or {}

      for _, child in ipairs(children) do
        local childRole = child:attributeValue("AXRole") or "unknown"
        local childSubrole = child:attributeValue("AXSubrole") or ""
        local childDesc = child:attributeValue("AXRoleDescription") or ""
        local childIdentifier = child:attributeValue("AXIdentifier") or ""

        if childRole == "AXToolbar" then
          hasToolbar = true
          local toolbarChildren = child:attributeValue("AXChildren") or {}
          toolbarItemCount = #toolbarChildren
        end

        if childRole == "AXGroup" then
          local groupChildren = child:attributeValue("AXChildren") or {}
          table.insert(titleBarChildren, "AXGroup(" .. #groupChildren .. " children, subrole=" .. childSubrole .. ")")
        end

        if childRole == "AXTabGroup" then
          local tabs = child:attributeValue("AXTabs") or child:attributeValue("AXChildren") or {}
          table.insert(titleBarChildren, "AXTabGroup(" .. #tabs .. " tabs)")
        end

        if childRole == "AXButton" then
          local buttonDesc = child:attributeValue("AXDescription") or child:attributeValue("AXTitle") or "?"
          table.insert(titleBarChildren, "AXButton:" .. buttonDesc)
        end

        -- Capture any element with interesting identifiers
        if childIdentifier ~= "" and not childIdentifier:match("^_") then
          table.insert(titleBarChildren, childRole .. "[" .. childIdentifier .. "]")
        end
      end

      print("Has AXToolbar: " .. tostring(hasToolbar) .. " (" .. toolbarItemCount .. " items)")

      if #titleBarChildren > 0 then
        print("Notable children: " .. table.concat(titleBarChildren, ", "))
      end

      -- Try to detect unified/integrated title bar style by checking
      -- if there's content at the top of the window
      local frame = win:frame()
      local topElements = {}
      for _, child in ipairs(children) do
        local childFrame = child:attributeValue("AXFrame")
        if childFrame then
          -- Check if element is near the top of the window (within ~50px)
          local relativeY = childFrame.y - frame.y
          if relativeY < 50 and relativeY >= 0 then
            local role = child:attributeValue("AXRole") or "?"
            table.insert(topElements, role)
          end
        end
      end
      if #topElements > 0 then
        print("Elements near top: " .. table.concat(topElements, ", "))
      end

      -- Check all attribute names for anything title/toolbar related
      local attrNames = axWin:attributeValue("AXAttributeNames") or axWin:attributeNames() or {}
      local titleRelated = {}
      for _, attr in ipairs(attrNames) do
        if attr:lower():match("title") or attr:lower():match("toolbar") or attr:lower():match("unified") then
          local val = axWin:attributeValue(attr)
          table.insert(titleRelated, attr .. "=" .. tostring(val))
        end
      end
      if #titleRelated > 0 then
        print("Title/Toolbar attrs: " .. table.concat(titleRelated, ", "))
      end
    else
      print("(Could not get AX element)")
    end
    print("")
  end
end
