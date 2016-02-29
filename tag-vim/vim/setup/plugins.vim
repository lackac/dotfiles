call plug#begin('~/.vim/plugged')

""" Color Theme

Plug 'altercation/vim-colors-solarized'

""" Language Support

Plug 'kchmck/vim-coffee-script'
Plug 'chrisbra/csv.vim'
Plug 'elixir-lang/vim-elixir'
Plug 'awetzel/elixir.nvim', { 'do': './install.sh' }
Plug 'jimenezrick/vimerl'
Plug 'fatih/vim-go'
Plug 'tpope/vim-haml'
Plug 'nono/vim-handlebars'
Plug 'digitaltoad/vim-jade'
Plug 'pangloss/vim-javascript'
Plug 'elzr/vim-json'
Plug 'groenewege/vim-less'
Plug 'tpope/vim-markdown'
Plug 'jtratner/vim-flavored-markdown'
Plug 'mmalecki/vim-node.js'
Plug 'vim-ruby/vim-ruby'
Plug 'rosstimson/scala-vim-support'
Plug 'cakebaker/scss-syntax.vim'
Plug 'wavded/vim-stylus'
Plug 'timcharper/textile.vim'

""" Tools

Plug 'rking/ag.vim'
Plug 'vim-airline/vim-airline'                            " lean & mean status/tabline for vim that's light as air
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-commentary'                               " toggle commenting with gc
Plug 'ap/vim-css-color'
Plug 'kien/ctrlp.vim'                                     " fuzzy file, buffer, mru, tag, etc finder
Plug 'fisadev/vim-ctrlp-cmdpalette'                       " command palette extension for CtrlP
Plug 'jasoncodes/ctrlp-modified.vim'                      " open locally modified files in your git-versioned projects
if has('python')
  Plug 'FelikZ/ctrlp-py-matcher'                          " fast vim CtrlP matcher based on python
end
Plug 'rizzatti/dash.vim'
Plug 'Raimondi/delimitMate'                               " insert mode auto-completion for quotes, parens, brackets, etc.
Plug 'Shougo/deoplete.nvim'                               " asynchronous completion framework for neovim
Plug 'tpope/vim-dispatch'                                 " TODO: decide which of these type of plugins to keep
Plug 'junegunn/vim-easy-align'                            " simple, easy-to-use alignment plugin
Plug 'editorconfig/editorconfig-vim'
"Plug 'mattn/emmet-vim'                                    " TODO: configure; greatly improve HTML & CSS workflow
Plug 'tpope/vim-endwise'                                  " automatically insert end in Ruby
Plug 'tpope/vim-eunuch'                                   " UNIX command wrappers (e.g. :Rename)
Plug 'terryma/vim-expand-region'                          " visually select increasingly larger regions
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'mattn/gist-vim'
Plug 'junegunn/goyo.vim'                                  " distraction-free writing in Vim
Plug 'sjl/gundo.vim'                                      " visualize your Vim undo tree
Plug 'michaeljsmith/vim-indent-object'
Plug 'pbrisbin/vim-mkdir'                                 " automatically create any non-existent directories before writing the buffer
Plug 'chrisbra/NrrwRgn'                                   " focus on a selected region
Plug 'tpope/vim-obsession'                                " continuously updated session files
Plug 'tpope/vim-projectionist'                            " granular project configuration using 'projections'
Plug 'tpope/vim-rbenv'
Plug 'thinca/vim-ref'                                     " integrated reference viewer
Plug 'tpope/vim-repeat'                                   " enable repeating supported plugin maps with .
Plug 'ngmy/vim-rubocop'
Plug 'duff/vim-scratch'
Plug 'tpope/vim-surround'                                 " quoting/parenthesizing made simple
Plug 'scrooloose/syntastic'                               " Syntax checking hacks for vim
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-line'
Plug 'kana/vim-textobj-user'
Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'tomtom/tlib_vim'                                    " some utility functions for vim
Plug 'christoomey/vim-tmux-navigator'                     " seamless navigation between tmux panes and vim splits
"Plug 'SirVer/ultisnips'                                   " TODO: start using this; the ultimate snippet solution for vim
Plug 'tpope/vim-unimpaired'                               " pairs of handy bracket mappings
Plug 'benmills/vimux'                                     " TODO: decide this or dispatch
Plug 'tpope/vim-vinegar'                                  " enhances netrw to make it more useful, trigger by pressing '-'
Plug 'sjl/vitality.vim'                                   " TODO: review if this is still necessary; make vim play nicely with iterm 2 and tmux
Plug 'mattn/webapi-vim'                                   " an interface to web apis, used by other plugins
Plug 'vim-scripts/YankRing.vim'                           " maintains a history of previous yanks, changes and deletes
Plug 'itspriddle/ZoomWin'                                 " zoom in/out of windows
Plug 't9md/vim-ruby-xmpfilter'                            " TODO: review using this with seeing_is_believing; helper for ruby's xmpfilter or seeing_is_believing
Plug 'amix/vim-zenroom2'                                  " companion to goyo which emulates an iA Writer environment

""" Framework Support

Plug 'tpope/vim-bundler'
Plug 'tpope/vim-cucumber'
Plug 'dsawardekar/ember.vim'
Plug 'sunaku/vim-ruby-minitest'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rake'
Plug 'thoughtbot/vim-rspec'

""" Let's be sensible

Plug 'tpope/vim-sensible'                                 " defaults everyone can agree on

call plug#end()
