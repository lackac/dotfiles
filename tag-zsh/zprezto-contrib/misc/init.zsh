#
# Miscellaneous and local configuration
#

export ERL_FLAGS="-kernel shell_history enabled"

export GOPATH=${ZDOTDIR:-$HOME}/.go
path=($GOPATH/bin $path)

if [[ -d /System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home/ ]]; then
  export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home/
fi

if [[ -d /usr/local/opt/android-sdk ]]; then
  export ANDROID_SDK_ROOT=/usr/local/opt/android-sdk
fi

if [[ -s ${ZDOTDIR:-$HOME}/.zprofile.local ]]; then
  source ${ZDOTDIR:-$HOME}/.zprofile.local
fi
