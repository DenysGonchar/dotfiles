typeset -U path
path+=(~/bin)

if [ -z "$LDFLAGS" ]; then
  export LDFLAGS=" -L/opt/homebrew/opt/openssl@1.1/lib "
fi

if [ -z "$CFLAGS" ]; then
  export CFLAGS=" -I/opt/homebrew/opt/openssl@1.1/include "
fi


