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
    "HP Z27k G3-V",
    "HP Z27k G3",
  },
  displayLayouts = {
    ["Built-in Retina Display"] = { "monocle", "tabbed-right" },
    ["S27C900P"] = { "main-left", "tabbed-right", "monocle" },
    ["LG SDQHD-V"] = { "tabbed-top", "main-top", "monocle" },
    ["LG SDQHD"] = { "main-left", "tabbed-right", "monocle" },
    ["HP Z27k G3"] = { "main-left", "tabbed-right", "monocle" },
    ["HP Z27k G3-V"] = { "main-top", "tabbed-top", "monocle" },
  },

  managedLayouts = {
    {
      ["LG SDQHD-V"] = {
        {
          layout = "tabbed-top",
          layoutOptions = { mainPaneRatio = 1 - 0.618 },
          windows = {
            "Slack",
            { app = "Brave Browser", title = "🐦$" },
            { app = "Brave Browser", title = "📦$" },
            { app = "Brave Browser", title = "🚗$" },
            { app = "Brave Browser", title = "🆙$" },
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
            { app = "Zed" },
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
            { app = "Zed" },
            { app = "Brave Browser", title = "🐦$", focus = true },
            { app = "Brave Browser", title = "📦$" },
            { app = "Brave Browser", title = "🚗$" },
            { app = "Brave Browser", title = "🆙$" },
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
