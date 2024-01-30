return {
  {
    "numToStr/Navigator.nvim",
    opts = {
      -- Save modified buffer(s) when moving to mux
      -- nil - Don't save (default)
      -- 'current' - Only save the current modified buffer
      -- 'all' - Save all the buffers
      auto_save = "current",

      -- Disable navigation when the current mux pane is zoomed in
      disable_on_zoom = true,

      -- Multiplexer to use
      -- 'auto' - Chooses mux based on priority (default)
      -- table - Custom mux to use
      mux = "auto",
    },
  },
}
