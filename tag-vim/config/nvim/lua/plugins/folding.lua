local ftMap = {
  vim = "indent",
  python = { "indent" },
  git = "",
}

local function providerSelector(bufnr)
  local function handleFallbackException(err, providerName)
    if type(err) == "string" and err:match("UfoFallbackException") then
      return require("ufo").getFolds(bufnr, providerName)
    else
      return require("promise").reject(err)
    end
  end

  return require("ufo")
    .getFolds(bufnr, "lsp")
    :catch(function(err)
      return handleFallbackException(err, "treesitter")
    end)
    :catch(function(err)
      return handleFallbackException(err, "indent")
    end)
end

local function goPreviousClosedAndPeek()
  require("ufo").goPreviousClosedFold()
  require("ufo").peekFoldedLinesUnderCursor()
end

local function goNextClosedAndPeek()
  require("ufo").goNextClosedFold()
  require("ufo").peekFoldedLinesUnderCursor()
end

local virtTextHandler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = (" ↙︎ %d "):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, { suffix, "MoreMsg" })
  return newVirtText
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      },
    },
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufRead",
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
      },
      {
        "zr",
        function()
          require("ufo").openFoldsExceptKinds()
        end,
      },
      {
        "zm",
        function()
          require("ufo").closeFoldsWith()
        end,
      },
      { "zp", goPreviousClosedAndPeek },
      { "zn", goNextClosedAndPeek },
      {
        "K",
        function()
          local winid = require("ufo").peekFoldedLinesUnderCursor()
          if winid then
            local bufnr = vim.api.nvim_win_get_buf(winid)
            local keys = { "a", "i", "o", "A", "I", "O", "gd", "gr" }
            for _, k in ipairs(keys) do
              -- Add a prefix key to fire `trace` action,
              -- if Neovim is 0.8.0 before, remap yourself
              vim.keymap.set("n", k, "<CR>" .. k, { noremap = false, buffer = bufnr })
            end
          else
            vim.lsp.buf.hover()
          end
        end,
      },
    },
    config = function()
      vim.o.fillchars = [[eob: ,fold:┄,foldopen:,foldsep:│,foldclose:]]
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      local ufo = require("ufo")

      ufo.setup({
        open_fold_hl_timeout = 400,
        provider_selector = function(_, filetype, _)
          return ftMap[filetype] or providerSelector
        end,
        close_fold_kinds = { "imports", "comment" },
        fold_virt_text_handler = virtTextHandler,
        enable_get_fold_virt_text = false,
        preview = {
          win_config = {
            border = { "", "─", "", "", "", "─", "", "" },
            winhighlight = "Normal:Folded",
            winblend = 0,
          },
          mappings = {
            scrollU = "<C-u>",
            scrollD = "<C-d>",
            jumpTop = "[",
            jumpBot = "]",
          },
        },
      })

      local ignore_filetypes = { "neo-tree" }

      -- detach from existing ignored file types
      vim.tbl_map(function(buf)
        if
          vim.api.nvim_buf_is_loaded(buf)
          and vim.tbl_contains(ignore_filetypes, vim.api.nvim_buf_get_option(buf, "filetype"))
        then
          ufo.detach(buf)
        end
      end, vim.api.nvim_list_bufs())

      -- detach from buffers with ignored filetypes right after opening them
      vim.api.nvim_create_autocmd("FileType", {
        pattern = ignore_filetypes,
        callback = function()
          ufo.detach()
          vim.opt_local.foldenable = false
        end,
      })
    end,
  },
}
