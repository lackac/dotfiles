return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                },
              },
            },
          },
        },
        sourcekit = {
          cmd = { "/usr/bin/sourcekit-lsp" },
          filetypes = { "swift", "c", "cpp", "objc", "objective-c", "objective-cpp" },
        },
      },
    },
  },
}
