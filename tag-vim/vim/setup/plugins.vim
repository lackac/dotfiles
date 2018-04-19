call plug#begin('~/.vim/plugged')

""" Color Theme

Plug 'altercation/vim-colors-solarized'

""" Language Support

Plug 'sheerun/vim-polyglot'         " a collection of language packs for Vim
Plug 'chrisbra/csv.vim'
Plug 'elixir-editors/vim-elixir'
Plug 'jimenezrick/vimerl'
Plug 'joukevandermaas/vim-ember-hbs'
Plug 'mmalecki/vim-node.js'
Plug 'cakebaker/scss-syntax.vim'

""" Tools

Plug 'rking/ag.vim'
Plug 'vim-airline/vim-airline'                            " lean & mean status/tabline for vim that's light as air
Plug 'vim-airline/vim-airline-themes'
Plug 'slashmili/alchemist.vim'                            " elixir completion, documentation lookup, other integrations
Plug 'tpope/vim-commentary'                               " toggle commenting with gc
Plug 'ap/vim-css-color'
Plug 'kien/ctrlp.vim'                                     " fuzzy file, buffer, mru, tag, etc finder
Plug 'fisadev/vim-ctrlp-cmdpalette'                       " command palette extension for CtrlP
Plug 'jasoncodes/ctrlp-modified.vim'                      " open locally modified files in your git-versioned projects
if has('python')
  Plug 'JazzCore/ctrlp-cmatcher', { 'do': './install.sh' }" better and faster fuzzy matching
end
Plug 'rizzatti/dash.vim'
Plug 'vim-scripts/dbext.vim'                              " database access to many dbms
Plug 'Raimondi/delimitMate'                               " insert mode auto-completion for quotes, parens, brackets, etc.
Plug 'Shougo/deoplete.nvim'                               " asynchronous completion framework for neovim
Plug 'tpope/vim-dispatch'                                 " used by vim-test for figuring out makeprg, not used directly
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
Plug 'ludovicchabant/vim-gutentags'                       " manages tag files
Plug 'lucidstack/hex.vim'                                 " nifty functions for your Elixir Hex dependencies
Plug 'michaeljsmith/vim-indent-object'
Plug 'ledger/vim-ledger'                                  " ledger filetype
Plug 'pbrisbin/vim-mkdir'                                 " automatically create any non-existent directories before writing the buffer
Plug 'sbdchd/neoformat'                                   " automatic code formatting
Plug 'neomake/neomake'                                    " async :make and linting framework for Neovim/Vim
Plug 'chrisbra/NrrwRgn'                                   " focus on a selected region
Plug 'tpope/vim-obsession'                                " continuously updated session files
"Plug 'tpope/vim-projectionist'                            " granular project configuration using 'projections'
Plug 'tpope/vim-rbenv'
Plug 'thinca/vim-ref'                                     " integrated reference viewer
Plug 'tpope/vim-repeat'                                   " enable repeating supported plugin maps with .
Plug 'ngmy/vim-rubocop'
Plug 'duff/vim-scratch'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'tpope/vim-surround'                                 " quoting/parenthesizing made simple
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-line'
Plug 'kana/vim-textobj-user'
Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'janko-m/vim-test'                                   " Flexible test runner that supports multiple frameworks and strategies
Plug 'tomtom/tlib_vim'                                    " some utility functions for vim
Plug 'christoomey/vim-tmux-navigator'                     " seamless navigation between tmux panes and vim splits
Plug 'freitass/todo.txt-vim'                              " Todo.txt support
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
Plug 'c-brenn/phoenix.vim'
Plug 'dsawardekar/ember.vim'
Plug 'sunaku/vim-ruby-minitest'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rake'

""" Let's be sensible

if !has('nvim')
  Plug 'tpope/vim-sensible'                                 " defaults everyone can agree on
end

call plug#end()
