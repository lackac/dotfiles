return {
  tilingMethod = "hhtwm",
  -- tilingMethod = "grid",
  -- tilingMethod = "autogrid",

  defaultLayouts = { "monocle", "main-left" },
  displayOrder = {
    "Built-in Retina Display",
    "S27C900P",
    "LG SDQHD-V",
    "LG SDQHD",
    "LF32TU87",
    "HP Z27k G3-V",
    "HP Z27k G3",
  },
  displayLayouts = {
    ["Built-in Retina Display"] = { "monocle", "tabbed-right" },
    ["S27C900P"] = { "main-left", "tabbed-right", "monocle" },
    ["LG SDQHD-V"] = { "main-top", "tabbed-top", "monocle" },
    ["LG SDQHD"] = { "main-left", "tabbed-right", "monocle" },
    ["LF32TU87"] = { "main-left", "main-right", "main-center", "tabbed-right", "monocle" },
    ["HP Z27k G3"] = { "main-left", "tabbed-right", "monocle" },
    ["HP Z27k G3-V"] = { "main-top", "tabbed-top", "monocle" },
  },

  managedLayouts = {
    {
      ["LG SDQHD-V"] = {
        {
          layout = "tabbed-top",
          layoutOptions = { mainPaneRatio = 0.5 },
          windows = {
            { app = "Brave Browser", title = "🐦$" },
            { app = "Brave Browser", title = "📦$" },
            { app = "Brave Browser", title = "🚗$" },
            "Slack",
            "Dash",
            "Finder",
          },
        },
      },
      ["S27C900P"] = {
        {
          layout = "tabbed-right",
          layoutOptions = { mainPaneRatio = 0.618 },
          windows = {
            { app = "kitty", focus = true },
          },
        },
        {
          layout = "main-left",
          layoutOptions = { mainPaneRatio = 0.618 },
          windows = {
            { app = "Brave Browser", title = "🌳$" },
            "Calendar",
            "Messages",
            "Timing",
            "Music",
          },
        },
      },
      ["Built%-in"] = {
        {
          layout = "monocle",
          windows = {
            "Slack",
            "Dash",
            "Finder",
          },
        },
      },
    },
    {
      order = { "Built%-in", "HP Z27k G3-V", "HP Z27k G3" },
      ["Built%-in"] = {
        {
          layout = "monocle",
          windows = {
            "Slack",
            "Dash",
            "Finder",
          },
        },
      },
      ["HP Z27k G3"] = {
        {
          layout = "tabbed-right",
          layoutOptions = { mainPaneRatio = 0.5 },
          windows = {
            "kitty",
            { app = "Brave Browser", title = "🐦$", focus = true },
            { app = "Brave Browser", title = "📦$" },
            { app = "Brave Browser", title = "🚗$" },
          },
        },
        {
          layout = "main-left",
          layoutOptions = { mainPaneRatio = 0.5 },
          windows = {
            { app = "Brave Browser", title = "🌳$" },
            "Calendar",
            "Messages",
            "Timing",
          },
        },
      },
      ["HP Z27k G3-V"] = {
        {
          layout = "tabbed-top",
          layoutOptions = { mainPaneRatio = 0.5 },
          windows = {
            "kitty",
          },
        },
      },
    },
  },
}
