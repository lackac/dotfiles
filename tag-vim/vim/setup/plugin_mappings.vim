nmap <leader>a :Ag -S 
nmap <leader>A :AgFromSearch<cr>

nmap <leader>b :BuffergatorToggle<cr>

nmap <leader>j :CoffeeCompile<cr>
vmap <leader>j :CoffeeCompile<cr>

imap <C-t> <esc>:CtrlP<cr>

nmap <silent> <leader>d <Plug>DashSearch

nmap <leader>gb :Gblame<CR>
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gl :Glog<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gA :Gcommit --amend -v<CR>
nmap <leader>gv :Gcommit -v<CR>
nmap <leader>gp :Git push<CR>

nmap <leader>n :NERDTreeToggle<cr>
nmap <leader>N :NERDTreeFind<cr>

xmap <leader>nr <Plug>NrrwrgnDo

nmap <leader>rt :call RunCurrentSpecFile()<CR>
nmap <leader>rs :call RunNearestSpec()<CR>
nmap <leader>rl :call RunLastSpec()<CR>

nmap <leader>tb :TagbarToggle<CR>

nmap <leader>tp :VimuxPromptCommand<cr>
nmap <leader>tl :VimuxRunLastCommand<cr>
nmap <leader>ti :VimuxInspectRunner<cr>
nmap <leader>tx :VimuxClosePanes<cr>
nmap <leader>ts :VimuxInterruptRunner<cr>

nmap <leader>z :Goyo<cr>

nmap <leader><tab>  :Scratch<cr>

vmap <leader>/ <plug>NERDCommenterToggle<CR>

nmap <leader>.= :Tabularize /=<CR>
vmap <leader>.= :Tabularize /=<CR>
nmap <leader>.> :Tabularize /=><CR>
vmap <leader>.> :Tabularize /=><CR>
nmap <leader>., :Tabularize /,\zs/l0l1<CR>
vmap <leader>., :Tabularize /,\zs/l0l1<CR>
nmap <leader>.: :Tabularize /:\zs/l0l1<CR>
vmap <leader>.: :Tabularize /:\zs/l0l1<CR>

nmap <C-W>! <Plug>Kwbd

nmap <C-Tab> :ChefFindAny<CR>
