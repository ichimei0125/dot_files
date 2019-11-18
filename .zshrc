# zsh Promt
autoload -Uz colors
colors

PROMPT="%{$fg[green]%}%n %{$fg[yellow]%}@[%m]: %{$fg[cyan]%}%~%{$reset_color%}
%# "

# Go
export GOPATH="/Users/ichimei0125/go:/Users/ichimei0125/workspace/go"
export GOBIN="/Users/ichimei0125/go/bin"

export PATH="$PATH:$GOBIN"

# pyenv
eval "$(pyenv init -)"

