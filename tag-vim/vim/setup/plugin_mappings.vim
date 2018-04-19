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

nmap <leader>mp :VimuxPromptCommand<cr>
nmap <leader>ml :VimuxRunLastCommand<cr>
nmap <leader>mi :VimuxInspectRunner<cr>
nmap <leader>mx :VimuxCloseRunner<cr>
nmap <leader>ms :VimuxInterruptRunner<cr>
nmap <leader>mc :VimuxRunCommand "cucumber <c-r>=expand("%")<cr>"<cr>

imap <expr><Tab> pumvisible() ? "\<C-n>" :
      \ neosnippet#expandable_or_jumpable() ?
      \   "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"
imap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
imap <expr><CR> pumvisible() && neosnippet#expandable() ?
      \ "\<Plug>(neosnippet_expand)" : "\<CR>\<Plug>DiscretionaryEnd"
smap <expr><Tab> neosnippet#expandable_or_jumpable() ?
      \   "\<Plug>(neosnippet_expand_or_jump)" : "\<Tab>"

nmap <leader>tn :TestNearest<CR>
nmap <leader>tf :TestFile<CR>
nmap <leader>ts :TestSuite<CR>
nmap <leader>tl :TestLast<CR>
nmap <leader>tv :TestVisit<CR>

nmap <leader>z :Goyo<cr>

nmap <leader><tab> :Scratch<cr>
