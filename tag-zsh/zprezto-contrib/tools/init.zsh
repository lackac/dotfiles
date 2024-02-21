#
# Loads and configures various tools and shortcuts
#

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# zoxide
if (( $+commands[zoxide] )); then
  eval "$(zoxide init --cmd cd zsh)"
fi

# starship
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# direnv
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# asdf
if [[ -f ${ZDOTDIR:-$HOME}/.asdf/asdf.sh ]]; then
  source ${ZDOTDIR:-$HOME}/.asdf/asdf.sh
  source ${ZDOTDIR:-$HOME}/.asdf/completions/asdf.bash
fi

if [[ -f ${ZDOTDIR:-$HOME}/.asdf/plugins/java/set-java-home.zsh ]]; then
  source ${ZDOTDIR:-$HOME}/.asdf/plugins/java/set-java-home.zsh
fi

# Load CLIs based on 100starlings/sub

if [[ -f ${XDG_CONFIG_HOME:-$HOME/.config}/subs ]]; then
  for sub in $(grep -v '^#' ${XDG_CONFIG_HOME:-$HOME/.config}/subs); do
    [[ ${sub:0:1} == "/" ]] || sub=$Code/$sub
    if [[ -x $sub ]]; then
      eval "$($sub init -)"
    fi
  done
fi

# aws
if [[ -s ${ZDOTDIR:-$HOME}/.aws/env ]]; then
  source ${ZDOTDIR:-$HOME}/.aws/env
fi

# k.sh
if [[ -s $Code/supercrabtree/k/k.sh ]]; then
  source $Code/supercrabtree/k/k.sh
fi

# 1Password CLI
if (( $+commands[op] )); then
  eval "$(op completion zsh)"
  compdef _op op
fi
if [[ -s $HOME/.config/op/plugins.sh ]]; then
  source $HOME/.config/op/plugins.sh
fi
