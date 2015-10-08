""" General Mappings (Normal, Visual, Operator-pending)

" help with the transitional period
nmap , :echoe "You've changed \<leader\> to \<space\>, remember?"<CR>

" format the entire file
nmap <leader>fef ggVG=

" format paragraph
nmap <leader>q gqip

" cd to the directory containing the file in the buffer
nmap <silent> <leader>cd :lcd %:h<CR>

" create the directory containing the file in the buffer
nmap <silent> <leader>md :!mkdir -p %:p:h<CR>

" some helpers to edit mode
" http://vimcasts.org/e/14
nmap <leader>ew :e <C-R>=expand('%:h').'/'<cr>
nmap <leader>es :sp <C-R>=expand('%:h').'/'<cr>
nmap <leader>ev :vsp <C-R>=expand('%:h').'/'<cr>
nmap <leader>et :tabe <C-R>=expand('%:h').'/'<cr>

" underline the current line with '='
nmap <silent> <leader>ul :t.<CR>Vr=

" toggle text wrapping
nmap <silent> <leader>tw :set invwrap wrap?<CR>

" find merge conflict markers
nmap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>

" map the arrow keys to be based on display lines, not physical lines
map <Down> gj
map <Up> gk

" toggle hlsearch with <leader>/
nmap <leader>/ :set invhlsearch hlsearch?<CR>

" yank visual to clipboard
vmap <C-c> "*y

" jump between parens with <tab>
nmap <tab> %
vmap <tab> %

" enter visual with just pasted text
nmap <leader>V V`]

" split vertically/horizontally and focus new window
nmap <leader>v <C-w>v<C-w>l
nmap <leader>s <C-w>s<C-w>j

" open file under cursor in a vertical split
nmap <C-w>f :vertical rightbelow wincmd f<cr>
nmap <C-w><C-f> <C-w>f

""" Command-Line Mappings

" after whitespace, insert the current directory into a command-line path
cnoremap <expr> <C-P> getcmdline()[getcmdpos()-2] ==# ' ' ? expand('%:p:h') : "\<C-P>"

" kills trailing whitespaces
command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>

" emacs like line editing
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <Esc>b <S-Left>
cnoremap <Esc>f <S-Right>

" allow saving of files as sudo when forgetting to start vim using sudo
cmap w!! %!sudo tee > /dev/null %

""" More complicated mappings

" jump between first column and first whitespace
function! FindHome()
  let current = col(".")
  exe "normal ^"
  let first_non_blank = col(".")
  if (current == first_non_blank)
    exe "normal 1|"
  endif
endfunction
nmap 0 :call FindHome()<cr>

" toggle ruby blocks
" requires the matchit plugin
function! s:ToggleRubyBlocks()
  let c = getline(".")[col(".")-1]
  if c =~ '[{}]'
    " don't use matchit for {,}
    exe 'normal! %s'.(c=='}' ? 'do' : 'end')."\<esc>``s".(c=='}' ? 'end' : 'do')."\<esc>"
  else
    let w = expand('<cword>')
    if w == 'do'
      " use matchit
      normal %
      exe "normal! ciw}\<esc>``ciw{\<esc>"
    elseif w == 'end'
      " use matchit
      normal %
      exe "normal! ciw{\<esc>``ciw}\<esc>"
    else
      throw 'Cannot toggle block: cursor is not on {, }, do, nor end'
    endif
  endif
endfunction
autocmd FileType ruby :nmap <buffer> <leader>d :call <sid>ToggleRubyBlocks()<cr>
