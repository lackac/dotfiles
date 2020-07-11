" SQL
let g:sql_type_default = 'pgsql'
let g:db_psql = 'postgresql:///sandbox'
let g:db_shiftbase_auth = 'postgresql:///shiftbase-auth'
let g:db_shiftbase_health = 'postgresql:///shiftbase-health'
let g:db_shiftbase_skills = 'postgresql:///shiftbase-skills'
let g:db_wesayy = 'postgresql:///wesayy_development'
let g:db_redshift_warehouse = 'postgresql://dev@data-warehouse.czm6beo87frd.eu-west-1.redshift.amazonaws.com:5439/ds'
let g:db_redshift_warehouse_admin = 'postgresql://admin@data-warehouse.czm6beo87frd.eu-west-1.redshift.amazonaws.com:5439/dev'
let g:db_redshift_warehouse_staging = 'postgresql://tubes@data-warehouse-staging.czm6beo87frd.eu-west-1.redshift.amazonaws.com:5439/ds'
let g:db_redshift_warehouse_staging_admin = 'postgresql://admin@data-warehouse-staging.czm6beo87frd.eu-west-1.redshift.amazonaws.com:5439/ds'
let g:db_mysql = 'mysql://root@localhost/sandbox'
let g:db_cplus = 'mysql://root@localhost/collectplus'

" setup b:db based on path
autocmd BufRead,BufNewFile ~/Code/CPlus/tubes/db/*.sql let b:db = g:db_redshift_warehouse_staging
autocmd BufRead,BufNewFile ~/Code/CPlus/tubes/db/*/*.sql let b:db = g:db_redshift_warehouse_staging

function! ToggleRedshiftDB()
  if b:db == g:db_redshift_warehouse
    let b:db = g:db_redshift_warehouse_staging
    echo "Switched to Redshift Staging"
  elseif b:db == g:db_redshift_warehouse_staging
    let b:db = g:db_redshift_warehouse
    echohl WarningMsg | echo "Switched to Redshift Production" | echohl None
  elseif b:db == g:db_redshift_warehouse_admin
    let b:db = g:db_redshift_warehouse_staging_admin
    echo "Switched to Redshift Staging (admin)"
  elseif b:db == g:db_redshift_warehouse_staging_admin
    let b:db = g:db_redshift_warehouse_admin
    echohl WarningMsg | echo "Switched to Redshift Production (admin)" | echohl None
  endif
  let b:db_current_job_elapsed = 0.0
endfunction
command ToggleRedshiftDB call ToggleRedshiftDB()

" sql query text object
vnoremap aq <esc>:call search(";", "cWz")<cr>:call search(";\\<bar>\\%^", "bsWz")<cr>:call search("\\v\\c^(select<bar>with<bar>insert<bar>update<bar>delete<bar>create<bar>drop<bar>truncate<bar>explain<bar>set<bar>analyze<bar>vacuum<bar>grant<bar>alter)\>", "Wz")<cr>vg`'
omap aq :normal vaq<cr>

" setup b:db and run queries with it
nmap <expr> <c-q> db#op_exec()
xmap <expr> <c-q> db#op_exec()

" show table schema for a Redshift table
function! RedshiftTableSchema()
  let [full, schema, table; rest] = matchlist(expand('<cWORD>'), '\%("\?\(\w\+\)"\?\.\)\?"\?\(\w\+\)"\?')
  let query = "SELECT * FROM admin.v_generate_tbl_ddl WHERE " .
        \ (len(schema) ? "schemaname = '" . schema . "' AND " : "") .
        \ "tablename = '" . table . "'"
  echo query
  call db#execute_command(v:false, 1, 0, query)
endfunction

nmap <expr> <leader><c-d> RedshiftTableSchema()

" use sql filetype for execution output
autocmd BufReadPost *.dbout setf sql

" show running time of current query in airline
function! DBJobElapsed()
  if exists("b:db_current_job_elapsed")
    if b:db == g:db_redshift_warehouse || b:db == g:db_redshift_warehouse_admin
      let icon = ' 恵ﮏ'
    elseif b:db == g:db_redshift_warehouse_staging || b:db == g:db_redshift_warehouse_staging_admin
      let icon = ' 恵'
    elseif b:db =~ '^postgresql:'
      let icon = '  '
    elseif b:db =~ '^mysql:'
      let icon = '  '
    else
      let icon = ' '
    endif
    return printf("\u00a0 %s %.1fs", icon, b:db_current_job_elapsed)
  else
    return ""
  endif
endfunction

call airline#parts#define_function('db_current', 'DBJobElapsed')
call airline#parts#define_accent('db_current', 'blue')
let g:airline_section_x = airline#section#create(['tagbar', 'gutentags', 'grepper', 'filetype', 'db_current'])

" function! AirlineInit()
"   call airline#parts#define('db_current', {
"         \ 'raw': '%{exists("b:db_current_job_elapsed") ? printf("\u00a0 DB: %.1fs", b:db_current_job_elapsed) : ""}',
"         \ 'accent': 'blue'
"         \ })
"   let g:airline_section_x = airline#section#create(['tagbar', 'gutentags', 'grepper', 'filetype', 'db_current'])
" endfunction
" autocmd User AirlineAfterInit call AirlineInit()
