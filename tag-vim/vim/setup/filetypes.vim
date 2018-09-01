""
"" Helpers
""

" Some file types should wrap their text
function! s:setupWrapping()
  setlocal wrap
  setlocal linebreak
  setlocal textwidth=72
  setlocal breakindent
  setlocal breakindentopt=shift:2,sbr
endfunction

""
"" File types
""

if has("autocmd")
  " .envrc files are shell scripts
  au BufNewFile,BufRead .envrc setf sh

  " In Makefiles, use real tabs, not tabs expanded to spaces
  au FileType make setlocal noexpandtab

  augroup filetype_elixir
    autocmd!
    " (disabled for slowness) Use syntax based folding for Elixir files
    "autocmd FileType elixir setlocal foldmethod=syntax
    " Always sync syntax from the start of the file
    autocmd FileType elixir autocmd BufEnter * :syntax sync fromstart
    " Run formatter before save and join it with last operation
    autocmd BufWritePre *.ex,*.exs try | undojoin | Neoformat | catch /^Vim\%((\a\+)\)\=:E790/ | endtry
  augroup END

  augroup markdown
    autocmd!
    autocmd BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
    autocmd FileType markdown call s:setupWrapping()
  augroup END

  " Make it easier to edit Yaml files with long lines
  au FileType yaml call s:setupWrapping()

  " Treat JSON files like JavaScript
  au BufNewFile,BufRead *.json setf javascript

  " Use gv as GraphViz extension
  au BufNewFile,BufRead *.gv setf dot

  " make Python follow PEP8 for whitespace ( http://www.python.org/dev/peps/pep-0008/ )
  au FileType python setlocal softtabstop=4 tabstop=4 shiftwidth=4

  " Remember last location in file, but not for commit messages.
  " see :help last-position-jump
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"" | endif

  " don't write backup file for crontab
  au BufNewFile,BufRead crontab.* setlocal nobackup nowritebackup
endif
