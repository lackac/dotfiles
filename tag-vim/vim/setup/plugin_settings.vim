let g:airline_powerline_fonts = 1
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline#extensions#tagbar#enabled = 0
let g:airline#extensions#tmuxline#enabled = 0

let g:alchemist_tag_disable = 1

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
  let g:ctrlp_match_func = { 'match': 'matcher#cmatch' }
endif

"let g:dbext_default_profile = 'psql'
let g:dbext_default_profile_psql = 'type=PGSQL:dbname=sandbox'
let g:dbext_default_profile_shiftbase_auth = 'type=PGSQL:dbname=shiftbase-auth'
let g:dbext_default_profile_shiftbase_health = 'type=PGSQL:dbname=shiftbase-health'
let g:dbext_default_profile_shiftbase_skills = 'type=PGSQL:dbname=shiftbase-skills'
let g:dbext_default_profile_wesayy = 'type=PGSQL:dbname=wesayy_development'
let g:dbext_default_profile_redshift_warehouse = 'type=PGSQL:host=data-warehouse.czm6beo87frd.eu-west-1.redshift.amazonaws.com:port=5439:dbname=ds:user=dev'
let g:dbext_default_profile_redshift_warehouse_admin = 'type=PGSQL:host=data-warehouse.czm6beo87frd.eu-west-1.redshift.amazonaws.com:port=5439:dbname=dev:user=admin'
let g:dbext_default_profile_mysql = 'type=MYSQL:dbname=sandbox:user=root'
let g:dbext_default_profile_cplus = 'type=MYSQL:dbname=collectplus:user=root'

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

call neomake#configure#automake('w')
function! OnNeomakeJobFinished() abort
  let context = g:neomake_hook_context
  if context.jobinfo.exit_code != 0
    echom printf('The job for maker %s exited non-zero: %s',
    \ context.jobinfo.maker.name, context.jobinfo.exit_code)
  else
    syntax sync fromstart
  endif
endfunction
augroup my_neomake_hooks
  au!
  autocmd User NeomakeJobFinished call OnNeomakeJobFinished()
augroup END

function! CustomTestTransform(cmd) abort
  return substitute(a:cmd, 'mix test apps/\([^/]*/\)', 'cd apps/\1 \&\& mix test ', '')
endfunction

let g:test#strategy = "neomake"
let g:test#custom_transformations = {'custom': function('CustomTestTransform')}
let g:test#transformation = 'custom'

let g:neosnippet#snippets_directory = "~/.vim/snippets"

let g:nrrw_rgn_nomap_nr = 1

let g:startify_lists = [
      \ { 'type': 'dir',       'header': ['MRU '. simplify(substitute(getcwd(), $HOME, '~', ''))] },
      \ { 'type': 'sessions',  'header': ['Sessions'] },
      \ { 'type': 'bookmarks', 'header': ['Bookmarks'] },
      \ { 'type': 'commands',  'header': ['Commands'] },
      \ ]
let g:startify_bookmarks = [
      \ '~/.vim/setup/settings.vim',
      \ '~/.vim/setup/mappings.vim',
      \ '~/.vim/setup/plugins.vim',
      \ '~/.vim/setup/plugin_settings.vim',
      \ '~/.vim/setup/plugin_mappings.vim',
      \ ]
let g:startify_commands = [
      \ { 'U': ':PlugUpdate' },
      \ { 'I': ':PlugInstall' },
      \ ]
let g:startify_files_number = 7
let g:startify_update_oldfiles = 1
let g:startify_change_to_vcs_root = 1

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
