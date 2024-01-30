alias vim=nvim
alias mux=tmuxinator

alias ls='eza'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias tree='ls --tree'

alias icat='kitty icat'

alias psg='ps aux | grep'
alias mwget='wget -v -c -x -r -l 0 -L -np'
alias :q=exit

alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"
alias ql="qlmanage -p &>/dev/null"

alias cal="gcal -s1 -H '\e[44;37m:\e[0m:\e[42;37m:\e[0m'"
alias cal-hu="cal -qHU"
alias cal-en="cal -qGB_EN"
alias cal-gb=cal-en
alias cal-uk=cal-en

alias gst='git status -sb'
alias gl='git log --decorate --graph --pretty="%C(auto)%h%d %C(bold)%s %C(blue)%ar%Creset %ad" --date=iso'
alias glb='gl --branches'
alias glp='git log -p --decorate --word-diff'
alias gco='git checkout'
alias gcm='git checkout master'
alias gcd='git checkout dev'
alias gcb='git checkout -b'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcp='git cherry-pick'
alias gp='git push'
alias gpo='git push origin'
alias gpu='git push -u origin'
alias gll='git pull'
alias gsps='git stash && git pull && git stash pop'
alias gm='git merge --no-ff'

alias b="bundle"
alias bi="b install"
alias bu="b update"
alias be="b exec"
alias binit="b install --path vendor && b package --all && echo 'vendor/ruby' >> .gitignore"

alias nls="npm list | sed -ne 's/^[├└][^ ]* //p'"
alias nlsg="npm list -g | sed -ne 's/^[├└][^ ]* //p'"

alias fs='foreman start'

alias prygem='gem install -i ~/.prygems'
alias r='script/rails'
alias rst='touch tmp/restart.txt'

alias repl='rlwrap -w-40 -p Green -C coffee jake console'

alias httpc='rlwrap http-console'
alias wbserv='heel -r output/ --no-highlighting'
