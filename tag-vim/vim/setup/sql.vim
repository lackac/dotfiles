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
autocmd BufRead,BufNewFile ~/Code/CPlus/tubes/db/*.sql let b:db = g:db_redshift_warehouse

" sql query text object
vnoremap aq <esc>:call search(";", "cWz")<cr>:call search(";\\<bar>\\%^", "bsWz")<cr>:call search("\\v\\c^(select<bar>with<bar>insert<bar>update<bar>delete<bar>create<bar>drop<bar>truncate<bar>set<bar>analyze<bar>vacuum)\>", "Wz")<cr>vg`'
omap aq :normal vaq<cr>

" setup b:db and run queries with it
nmap <expr> <c-q> db#op_exec()
xmap <expr> <c-q> db#op_exec()

" use sql filetype for execution output
autocmd BufReadPost *.dbout setf sql

" show running time of current query in airline
function! AirlineInit()
  call airline#parts#define('db_current', {
        \ 'raw': '%{exists("b:db_current_job_elapsed") ? printf("\u00a0 DB: %.1fs", b:db_current_job_elapsed) : ""}',
        \ 'accent': 'blue'
        \ })
  let g:airline_section_x = airline#section#create(['tagbar', 'gutentags', 'grepper', 'filetype', 'db_current'])
endfunction
autocmd User AirlineAfterInit call AirlineInit()
