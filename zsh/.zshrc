ZSH_THEME="robbyrussell"
# zsh Promt
autoload -Uz colors
colors

# 启用选项
#setopt prompt_subst
#PROMPT="%{$fg[green]%}%n %{$fg[yellow]%}@[%m]: %{$fg[cyan]%}%~%{$reset_color%}"$'\n'"%# "
PS1="%{$fg[red]%}%n %{$fg[cyan]%}@[%m]: %{$fg[yellow]%}%~%{$reset_color%}"$'\n'"%# "
#PS1='%F{red}%n%f@%F{cyan}%m%f %F{yellow}%1~%f %# '
# 启用右提示符
RPS1='%F{green}[%?] %f'

export LANG=en_US

# homebrew
export PATH="/opt/homebrew/bin:$PATH"

# Go
#export GOPATH="/Users/ichimei0125/go:/Users/ichimei0125/workspace/go"
export GOBIN="/Users/shi/go/bin"
export PATH="$PATH:$GOBIN"

# alias
# alias for updatedb
alias updatedb='sudo /usr/libexec/locate.updatedb'
# alias for jellyfin
alias jellyfinrun='sudo launchctl start com.localhost.jellyfin.plist'
alias jellyfinstop='sudo launchctl stop com.localhost.jellyfin.plist'

# nvm
#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pyenv
export PATH="$PATH:$HOME/.pyenv/bin"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# pyenv alias
alias py311='source ~/.virtualenv/py311/bin/activate'
alias py312='source ~/.virtualenv/py312/bin/activate'
# python pj
export PYTHONPATH="/Users/shi/workspace/Github/PredStock"

# open same directory in new tab
precmd () {print -Pn "\e]2; %~/ \a"}
preexec () {print -Pn "\e]2; %~/ \a"}

# Load all the configuration files from ~/.zsh.d/
for config_file in ~/.zsh.d/*.zsh; do
    source "$config_file"
done
