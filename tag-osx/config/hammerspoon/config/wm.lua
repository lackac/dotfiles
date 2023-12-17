return {
  tilingMethod = "hhtwm",
  -- tilingMethod = "grid",
  -- tilingMethod = "autogrid",

  defaultLayouts = { "monocle", "main-left" },
  displayOrder = {
    "Built-in Retina Display",
    "LG SDQHD",
    "LF32TU87",
  },
  displayLayouts = {
    ["Built-in Retina Display"] = { "monocle", "tabbed-right" },
    ["LG SDQHD"] = { "main-top", "main-center", "tabbed-top", "monocle" },
    ["LF32TU87"] = { "main-left", "main-right", "main-center", "tabbed-right", "monocle" },
    ["HP Z27k G3"] = { "main-left", "tabbed-right", "monocle" },
  },

  managedLayouts = {
    {
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
      ["LG SDQHD"] = {
        {
          layout = "main-top",
          layoutOptions = { mainPaneRatio = 0.618 },
          windows = { "kitty" },
        },
      },
      ["LF32TU87"] = {
        {
          layout = "main-left",
          layoutOptions = { mainPaneRatio = 0.618 },
          windows = {
            { app = "Brave Browser", title = "🐦$", focus = true },
            { app = "Brave Browser", title = "📦$" },
            { app = "Brave Browser", title = "🚗$" },
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
          },
        },
      },
    },
    {
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
    },
  },
}
