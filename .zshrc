# zsh Promt
autoload -Uz colors
colors

PROMPT="%{$fg[green]%}%n %{$fg[yellow]%}@[%m]: %{$fg[cyan]%}%~%{$reset_color%}"$'\n'"%# "

# Go
export GOPATH="/Users/ichimei0125/go:/Users/ichimei0125/workspace/go"
export GOBIN="/Users/ichimei0125/go/bin"

export PATH="$PATH:$GOBIN"

# pyenv
eval "$(pyenv init -)"

# open same directory in new tab
precmd () {print -Pn "\e]2; %~/ \a"}
preexec () {print -Pn "\e]2; %~/ \a"}
