""" Basic Setup

let mapleader = ","   " use comma as leader
set nocompatible      " use vim, no vi defaults
set relativenumber    " show relative line numbers
set number            " show line number on current line
set ruler             " show line and column number
set encoding=utf-8    " set default encoding to UTF-8
set history=1000      " number of command-lines that are remembered
set showcmd           " show (partial) command in status line
set hidden            " don't unload buffer when it is abandoned
set wildmenu          " use menu for command line completion

""" Display

set cursorline        " highlight the screen line of the cursor
set scrolloff=3       " minimum nr. of lines above and below cursor
set colorcolumn=+0,+8 " highlight columns 72 and 80
set list              " show invisible characters
set laststatus=2      " always show status line

""" Whitespace

set textwidth=72  " maximum width of text that is being inserted
set autoindent    " autoindent lines
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
set formatoptions+=j    " remove a comment leader when joining lines
set showmatch           " briefly jump to matching bracket if insert one
set backspace=indent,eol,start " backspace through everything in insert mode

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

""" Searching

set hlsearch    " highlight matches
set incsearch   " incremental searching
set ignorecase  " searches are case insensitive...
set smartcase   " ... unless they contain at least one capital letter

""" Wild settings

" Disable output and VCS files
set wildignore+=*.o,*.out,*.obj,.git,.hg,.svn,*.rbc,*.rbo,*.pyc,*.pyo,*.class,*.o,*.gem

" Disable archive files
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz

" Ignore bundler and sass cache
set wildignore+=*/vendor/ruby/*,*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*

" Ignore node_modules
set wildignore+=*/node_modules/*

" Ingore tmp, log, and generated directories
set wildignore+=*/tmp/*,*/log/*,*/build/*,*/coverage/*,*/.ctrlp_cache/*

" Disable tmp, backup, socket, and generated files
set wildignore+=*.swp,*~,._*,*.sock

""" Backup and swap files

set backupdir=~/tmp/vim/backup/,~/tmp,/tmp,.  " where to put backup files.
set directory=~/tmp/vim/tmp/,~/tmp,/tmp,.     " where to put swap files.
set undodir=~/tmp/vim/undo/,~/tmp,/tmp,.      " where to put undo information
set undofile                                  " automatically save undo history to an undo file
