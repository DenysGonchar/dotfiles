## aliases
alias ll='ls -ahl'

## prompt
autoload -U colors && colors
setopt PROMPT_SUBST
prompt=$'\n'"%{$fg[cyan]%}%D{%d-%b-%y} %{$fg[magenta]%}%T %{$fg[yellow]%}%~"
prompt+="%{$fg[green]%}\$(git branch 2> /dev/null | sed -ne 's/^*//p')"$'\n'
prompt+="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m%{$reset_color%} => "

## asdf-vm.com
. /opt/homebrew/opt/asdf/libexec/asdf.sh


