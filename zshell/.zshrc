## aliases
alias ll='ls -ahl'

## prompt
autoload -U colors && colors
setopt PROMPT_SUBST
prompt=$'\n'"%{$fg[cyan]%}%D{%d-%b-%y} %{$fg[magenta]%}%T %{$fg[yellow]%}%~"
prompt+="%{$fg[green]%}\$(git branch 2> /dev/null | sed -ne 's/^*//p')"$'\n'
prompt+="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m%{$reset_color%} => "

## https://mise.jdx.dev/shell-setup.html
eval "$(mise activate zsh)"

## autocompletion for various tools
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -Uz compinit
compinit
source <(kubectl completion zsh)

## tab completion (note that compinit must be executed before these commands)
zstyle ':completion:*' menu false
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'

## key bindings
bindkey "^[[5~" history-beginning-search-backward ## pg-up
bindkey "^[[6~" history-beginning-search-forward  ## pg-down
bindkey "^[[H" beginning-of-line                  ## home
bindkey "^[[F" end-of-line                        ## end
bindkey "^[[1;2D" backward-word                   ## shift-left
bindkey "^[[1;2C" forward-word                    ## shift-right
bindkey "^[[1;2A" up-line                         ## shift-up
bindkey "^[[1;2B" down-line                       ## shift-down
bindkey "^[[A" up-history                         ## up
bindkey "^[[B" down-history                       ## down

## shift-tab for filename completion
zle -C complete-file complete-word _generic
zstyle ':completion:complete-file::::' completer _files
bindkey '^[[Z' complete-file

## custom zshell options, use option names as in documentation:
##     https://zsh.sourceforge.io/Doc/Release/Options.html
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt INTERACTIVE_COMMENTS
setopt AUTO_CD

## direnv hook
eval "$(direnv hook zsh)"
