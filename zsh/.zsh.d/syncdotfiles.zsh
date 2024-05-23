#!/bin/zsh

function get_dotfiles {
    declare -A dot_files
    dot_files=(
        ["/Users/shi/.zshrc"]="/Users/shi/workspace/Github/dot_files/zsh/.zshrc"
        ["/Users/shi/.zsh.d/syncdotfiles.zsh"]="/Users/shi/workspace/Github/dot_files/zsh/.zsh.d/syncdotfiles.zsh"
    )
    echo ${(kv)dot_files}
}

function gitpushdotfiles {
    git_repo="/Users/shi/workspace/Github/dot_files"
    dot_files=($(get_dotfiles))

    for ((i=1; i<=${#dot_files[@]}; i+=2)); do
        cp "${dot_files[i]}" "${dot_files[i+1]}"
    done

    now_path=$(pwd)
    cd $git_repo
    git add .
    git commit -m "update by gitdotfiles"
    git push
    cd $now_path
}

function gitpulldotfiles {
    git_repo="/Users/shi/workspace/Github/dot_files"
    dot_files=($(get_dotfiles))

    now_path=$(pwd)
    cd $git_repo
    git pull

    for ((i=1; i<=${#dot_files[@]}; i+=2)); do
        cp "${dot_files[i+1]}" "${dot_files[i]}"
    done

    cd $now_path
}

# Usage
# gitpushdotfiles
# gitpulldotfiles
