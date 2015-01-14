let g:airline_powerline_fonts = 1
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline#extensions#tagbar#enabled = 0
let g:airline#extensions#tmuxline#enabled = 0
call airline#parts#define_function('pencil', 'PencilMode')
let g:airline_section_x = airline#section#create_right(['pencil', 'filetype'])

let g:buffergator_suppress_keymaps = 1

let g:ctrlp_map = '<C-t>'
if exists(getcwd()."/.git")
  let g:ctrlp_working_path_mode = 2
else
  let g:ctrlp_working_path_mode = 0
end
let g:ctrlp_open_multiple_files = '2vjr'
let g:ctrlp_show_hidden = 1
let g:ctrlp_cache_dir = $HOME."/.cache/ctrlp"
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_custom_ignore = {
  \ 'dir': '\v[\/](_site|build)'
  \ }

let NERDTreeChDirMode = 2
let NERDTreeIgnore = ['\.git$', '\.pyc$', '\.pyo$', '\.rbc$', '\.rbo$', '\.class$', '\.o$', '\~$', '^tmp$', '^log$', '\.bundle$', '\.sass-cache', '\.ctrlp_cache', '\.swp$', '^build$', '^coverage$', '\.sock$']
let NERDTreeQuitOnOpen = 1
let NERDTreeShowHidden = 1

augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
  autocmd FileType text         call pencil#init()
augroup END

let g:rspec_command = 'call VimuxRunCommand("spring rspec {spec}")'

let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['html'] }
let g:syntastic_enable_signs=1
let g:syntastic_quiet_messages = {'level': 'warnings'}
let g:syntastic_auto_loc_list=2

let g:tmuxline_theme = 'zenburn'
let g:tmuxline_powerline_separators = 0
let g:tmuxline_preset = {
  \ 'a'      : '#S',
  \ 'win'    : ['#I', '#W'],
  \ 'cwin'   : ['#I', '#W', '#F'],
  \ 'x'      : ['#(whoami)@#h'],
  \ 'y'      : ['%F', '%a'],
  \ 'z'      : '%R',
  \ 'options': {'status-justify': 'centre'}
  \ }
let g:tmuxline_separators = {
  \ 'left'     : '',
  \ 'left_alt' : '∙',
  \ 'right'    : '',
  \ 'right_alt': '∙',
  \ 'space'    : ' '
  \ }

let g:UltiSnipsListSnippets="<S-C-J>"
let g:UltiSnipsExpandTrigger="<C-J>"
let g:UltiSnipsJumpForwardTrigger="<C-J>"
let g:UltiSnipsJumpBackwardTrigger="<C-K>"

let g:vitality_fix_focus = 0 " don't let vitality mess up things with focus handling

"autocmd FileType ruby nmap <buffer> <C-d> <Plug>(xmpfilter-mark)
autocmd FileType ruby xmap <buffer> <C-d> <Plug>(xmpfilter-mark)
autocmd FileType ruby imap <buffer> <C-d> <Plug>(xmpfilter-mark)
autocmd FileType ruby nmap <buffer> <C-e> <Plug>(xmpfilter-run)
autocmd FileType ruby xmap <buffer> <C-e> <Plug>(xmpfilter-run)
autocmd FileType ruby imap <buffer> <C-e> <Plug>(xmpfilter-run)
