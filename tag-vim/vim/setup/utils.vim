source ~/.vim/setup/sql.vim

function! Sum(number, ...)
  let b:sum = get(b:, "sum", 0) + a:number
  if a:0 == 1 || a:1 = 'o'
    return a:number
  elseif a:1 = 't'
    return b:sum
  end
endfunction

function! SumFloat(number, ...)
  let float = type(a:number) == v:t_string ? str2float(a:number) : a:number
  let b:sum = get(b:, "sum", 0.0) + float
  if a:0 == 0 || a:1 == 'o'
    return a:number
  elseif a:1 == 'f'
    return float
  elseif a:1 == 't'
    return b:sum
  end
endfunction

