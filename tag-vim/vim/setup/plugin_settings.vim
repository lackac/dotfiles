let g:airline_powerline_fonts = 1
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline#extensions#tagbar#enabled = 0
let g:airline#extensions#tmuxline#enabled = 0

let g:ctrlp_map = '<C-t>'
let g:ctrlp_root_markers = ['Gemfile', 'package.json']
let g:ctrlp_open_multiple_files = '2vjr'
let g:ctrlp_show_hidden = 1
let g:ctrlp_cache_dir = $HOME."/.cache/ctrlp"
let g:ctrlp_clear_cache_on_exit = 0
if executable('ag')
  let g:ctrlp_user_command = 'ag -l -f --nocolor --hidden --ignore .git . %s'
  let g:ctrlp_use_caching = 0
endif
if has('python')
  let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
endif

let g:deoplete#enable_at_startup = 1

call expand_region#custom_text_objects({
  \ 'a]' :1,
  \ 'ab' :1,
  \ 'aB' :1,
  \ 'ii' :0,
  \ 'ai' :0,
  \ })
call expand_region#custom_text_objects('ruby', {
  \ 'im' :0,
  \ 'am' :0,
  \ })

let g:gutentags_cache_dir = '~/.tags_cache'

augroup markdown
  autocmd!
  autocmd BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

let g:rspec_command = 'call VimuxRunCommand("rspec {spec}")'

let g:syntastic_ruby_checkers = ["mri", "rubocop"]
let g:syntastic_ruby_mri_exec = '/Users/LacKac/.rbenv/shims/ruby'
let g:syntastic_ruby_rubocop_exec = '/Users/LacKac/.rbenv/shims/rubocop'

let g:neosnippet#disable_runtime_snippets = { '_': 1 }
let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#snippets_directory = '~/.vim/plugged/vim-snippets/snippets'

let g:vitality_fix_focus = 0 " don't let vitality mess up things with focus handling

"autocmd FileType ruby nmap <buffer> <C-d> <Plug>(xmpfilter-mark)
autocmd FileType ruby xmap <buffer> <C-d> <Plug>(xmpfilter-mark)
autocmd FileType ruby imap <buffer> <C-d> <Plug>(xmpfilter-mark)
autocmd FileType ruby nmap <buffer> <C-e> <Plug>(xmpfilter-run)
autocmd FileType ruby xmap <buffer> <C-e> <Plug>(xmpfilter-run)
autocmd FileType ruby imap <buffer> <C-e> <Plug>(xmpfilter-run)

if has('nvim')
  " removed 'key', 'oft', 'sn', 'tx' options which do not work with nvim
  let g:zoomwin_localoptlist = ["ai","ar","bh","bin","bl","bomb","bt","cfu","ci","cin","cink","cino","cinw","cms","com","cpt","diff","efm","eol","ep","et","fenc","fex","ff","flp","fo","ft","gp","imi","ims","inde","inex","indk","inf","isk","kmp","lisp","mps","ml","ma","mod","nf","ofu","pi","qe","ro","sw","si","sts","spc","spf","spl","sua","swf","smc","syn","ts","tw","udf","wfh","wfw","wm"]
endif
