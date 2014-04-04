#!/bin/sh

export PATH="$HOME/bin:$HOME/.prygems/bin:/usr/local/bin:/usr/local/sbin:$PATH"

# This breaks stuff
#export DYLD_LIBRARY_PATH="/usr/local/lib:/usr/lib"

export EDITOR=vim

#stty erase 
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#bind -f ~/.inputrc

export RUBY_HEAP_MIN_SLOTS=1000000
export RUBY_HEAP_SLOTS_INCREMENT=1000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_GC_MALLOC_LIMIT=1000000000
export RUBY_HEAP_FREE_MIN=500000

export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home/
export ANDROID_SDK_ROOT=/usr/local/Cellar/android-sdk/r20.0.1

[[ -s ~/.tmuxinator/scripts/tmuxinator ]] && source ~/.tmuxinator/scripts/tmuxinator

[[ -f ~/.custom_profile ]] && source ~/.custom_profile
