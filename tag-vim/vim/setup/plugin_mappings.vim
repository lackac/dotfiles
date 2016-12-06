nmap <leader>a :Ag! -S<space>
nmap <leader>A :AgFromSearch<cr>

nmap <leader>j :CoffeeCompile<cr>
vmap <leader>j :CoffeeCompile<cr>

imap <C-t> <esc>:CtrlP<cr>
nmap <silent> <C-e>] :CtrlPBufTagAll<cr>
nmap <silent> <C-e>b :CtrlPBuffer<cr>
nmap <silent> <C-e>p :CtrlPCmdPalette<cr>
nmap <silent> <C-e>g :CtrlPModified<cr>

nmap <silent> <leader>d <Plug>DashSearch
nmap <silent> <leader>D <Plug>DashGlobalSearch

vmap <Enter> <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

nmap <leader>gb :Gblame<CR>
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gl :Glog<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gA :Gcommit --amend -v<CR>
nmap <leader>gv :Gcommit -v<CR>
nmap <leader>gp :Git push<CR>

xmap <leader>nr <Plug>NrrwrgnDo

imap <expr><TAB> pumvisible() ? "\<C-n>" :
      \ neosnippet#expandable_or_jumpable() ?
      \   "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
imap <expr><CR> pumvisible() && neosnippet#expandable() ?
      \ "\<Plug>(neosnippet_expand)" : "\<CR>\<Plug>DiscretionaryEnd"

nmap <leader>rt :call RunCurrentSpecFile()<CR>
nmap <leader>rs :call RunNearestSpec()<CR>
nmap <leader>rl :call RunLastSpec()<CR>

nmap <leader>tp :VimuxPromptCommand<cr>
nmap <leader>tl :VimuxRunLastCommand<cr>
nmap <leader>ti :VimuxInspectRunner<cr>
nmap <leader>tx :VimuxCloseRunner<cr>
nmap <leader>ts :VimuxInterruptRunner<cr>
nmap <leader>tc :VimuxRunCommand "cucumber <c-r>=expand("%")<cr>"<cr>

nmap <leader>z :Goyo<cr>

nmap <leader><tab> :Scratch<cr>
