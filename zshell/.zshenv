typeset -U path
path+=(~/bin)

if [ -z "$LDFLAGS" ]; then
  export LDFLAGS=" -L/opt/homebrew/lib "
fi

if [ -z "$CFLAGS" ]; then
  export CFLAGS=" -I/opt/homebrew/include "
fi


