package.path = package.path
  .. ";"
  .. vim.fn.expand("$HOME")
  .. "/.asdf/installs/lua/5.1.5/luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path
  .. ";"
  .. vim.fn.expand("$HOME")
  .. "/.asdf/installs/lua/5.1.5/luarocks/share/lua/5.1/?.lua;"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
