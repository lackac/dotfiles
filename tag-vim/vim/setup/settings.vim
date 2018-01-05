""" Basic Setup

let mapleader = " "   " use space as leader
set nocompatible      " use vim, no vi defaults
set relativenumber    " show relative line numbers
set number            " show line number on current line
set encoding=utf-8    " set default encoding to UTF-8
set hidden            " don't unload buffer when it is abandoned
set wildmode=longest:full,full " shell like autocompletion for paths

""" Layout

set splitbelow        " put the new window below the current one
set splitright        " put the new window right of the current one

""" Display

set cursorline        " highlight the screen line of the cursor
set colorcolumn=+0    " highlight columns 72 and 80
set list              " show invisible characters

""" Whitespace

set textwidth=80  " maximum width of text that is being inserted
set nowrap        " don't wrap lines
set tabstop=2     " a tab is two spaces
set shiftwidth=2  " an autoindent (with <<) is two spaces
set expandtab     " use spaces, not tabs

""" Editing

set formatoptions=""    " how automatic formatting is to be done
set formatoptions+=q    " allow formatting of comments with "gq"
set formatoptions+=r    " automatically insert the current comment leader after hitting <cr> in insert mode
set formatoptions+=n    " when formatting text, recognize numbered lists
set formatoptions+=1    " don't break a line after a one-letter word
if v:version >= 704
  set formatoptions+=j  " remove a comment leader when joining lines
end
set showmatch           " briefly jump to matching bracket if insert one

""" Folding

set foldmethod=indent             " folding on indent by default
set foldnestmax=4                 " maximum fold depth
set nofoldenable                  " do not fold by default

""" List chars

set listchars=""                  " Reset the listchars
set listchars=tab:▸\              " display tabs as "▸"
set listchars+=trail:·            " display trailing spaces as "·"
set listchars+=eol:¬              " display end of line as "¬"
set listchars+=extends:>          " the character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " the character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set showbreak=↳                   " the character to show at the start of lines that have
                                  " been wrapped

""" Searching

set hlsearch    " highlight matches
set ignorecase  " searches are case insensitive...
set smartcase   " ... unless they contain at least one capital letter
if has("nvim")
  set inccommand=nosplit " live substitution previews
endif

""" Backup and swap files

set backupdir=~/tmp/vim/backup/,~/tmp,/tmp,.  " where to put backup files.
set directory=~/tmp/vim/tmp/,~/tmp,/tmp,.     " where to put swap files.
set undodir=~/tmp/vim/undo/,~/tmp,/tmp,.      " where to put undo information
set undofile                                  " automatically save undo history to an undo file
