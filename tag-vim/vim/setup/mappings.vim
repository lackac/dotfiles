""" General Mappings (Normal, Visual, Operator-pending)

" toggle paste mode
nmap <silent> <F4> :set invpaste<CR>:set paste?<CR>
imap <silent> <F4> <ESC>:set invpaste<CR>:set paste?<CR>

" format the entire file
nmap <leader>fef ggVG=

" format paragraph
nmap <leader>q gqip

" upper/lower word
nmap <leader>u mQviwU`Q
nmap <leader>l mQviwu`Q

" upper/lower first char of word
nmap <leader>U mQgewvU`Q
nmap <leader>L mQgewvu`Q

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

" swap two words
nmap <silent> gw :s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR>`'

" underline the current line with '='
nmap <silent> <leader>ul :t.<CR>Vr=

" set text wrapping toggles
nmap <silent> <leader>tw :set invwrap<CR>:set wrap?<CR>

" find merge conflict markers
nmap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>

" map the arrow keys to be based on display lines, not physical lines
map <Down> gj
map <Up> gk

" toggle hlsearch with <leader>/
nmap <leader>/ :set hlsearch! hlsearch?<CR>

" adjust viewports to the same size
map <Leader>= <C-w>=

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

" search Dash for word under cursor
function! SearchDash()
  let s:browser = "/usr/bin/open"
  let s:wordUnderCursor = expand("<cword>")
  let s:url = "dash://".s:wordUnderCursor
  let s:cmd ="silent ! " . s:browser . " " . s:url
  execute s:cmd
  redraw!
endfunction
map <leader>D :call SearchDash()<CR>
