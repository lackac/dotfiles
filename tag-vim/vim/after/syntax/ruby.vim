let s:bcs = b:current_syntax
unlet b:current_syntax
syntax include @SQL syntax/plsql.vim
unlet b:current_syntax
syntax include @JS syntax/javascript.vim
let b:current_syntax = s:bcs
syntax region HereDocSQL matchgroup=Statement start=+<<-\?\(['"]\?\)\z(\s*SQL\s*\)\1+ end=+^\s*\z1$+ contains=@SQL
syntax region HereDocJS matchgroup=Statement start=+<<-\?\(['"]\?\)\z(\s*\(JS\|MAP\|REDUCE\|FINALIZE\)\s*\)\1+ end=+^\s*\z1$+ contains=@JS
