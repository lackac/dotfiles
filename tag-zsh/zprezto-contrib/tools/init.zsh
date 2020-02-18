#
# Loads and configures various tools and shortcuts
#

# direnv
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# asdf
if [[ -f ${ZDOTDIR:-$HOME}/.asdf/asdf.sh ]]; then
  source ${ZDOTDIR:-$HOME}/.asdf/asdf.sh
  source ${ZDOTDIR:-$HOME}/.asdf/completions/asdf.bash
fi

# tmuxinator
if [[ -s ${ZDOTDIR:-$HOME}/.tmuxinator/scripts/tmuxinator ]]; then
  source ${ZDOTDIR:-$HOME}/.tmuxinator/scripts/tmuxinator
fi

# 100s
if [[ -d $Code/100Starlings/100s/bin ]]; then
  eval "$($Code/100Starlings/100s/bin/100s init -)"
fi

# cplus
if [[ -d $Code/CPlus/cplus/bin ]]; then
  eval "$($Code/CPlus/cplus/bin/cplus init -)"
fi

# aws
if [[ -s ${ZDOTDIR:-$HOME}/.aws/env ]]; then
  source ${ZDOTDIR:-$HOME}/.aws/env
fi

# k.sh
if [[ -s $Code/supercrabtree/k/k.sh ]]; then
  source $Code/supercrabtree/k/k.sh
fi
