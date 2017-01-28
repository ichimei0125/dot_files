PS1='\[\e[0;33m\]\u\[\e[m\] \[\e[1;32m\]\w\[\e[m\] \n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\[\e[0;31m\]\$ \[\e[m\]\[\e[0;37m\]'
export PATH="/usr/local/sbin:$PATH"

# in case of homebrew's "GitHub API limit" error
export HOMEBREW_GITHUB_API_TOKEN=

# alias for pip to update all
alias pipup='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U'
alias pip3up='pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip3 install -U'
