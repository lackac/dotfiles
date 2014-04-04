alias psg='ps aux | grep'
alias crontab='EDITOR=vim crontab'
alias mwget='wget -v -c -x -r -l 0 -L -np'
alias :q=exit
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

alias gd='git diff -w "$@" | mvim -R -'
alias gst='git status -sb'
alias gl='git log --decorate --graph --pretty="%C(auto)%h %d %s %Cblue%ad%Creset" --date=relative'
alias glb='gl --branches'
alias glp='git log -p --decorate --word-diff'
alias gco='git checkout'
alias gcm='git checkout master'
alias gcd='git checkout develop'
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

alias hpr='hub pull-request -b dev'

alias kst='knife status'
alias ks='knife search'
alias ksn='knife search node'
alias kn='knife node'
alias kne='knife node edit'
alias kns='knife node show'
alias kcu='knife cookbook upload'

alias fs='foreman start'

alias prygem='gem install -i ~/.prygems'
alias r='script/rails'
alias rst='touch tmp/restart.txt'

alias repl='rlwrap -w-40 -p Green -C coffee jake console'

alias httpc='rlwrap http-console'
alias wbserv='heel -r output/ --no-highlighting'

# Global aliases

alias -g C='| wc -l'
alias -g EG='|& egrep'
