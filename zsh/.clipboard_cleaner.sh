#!/bin/zsh

interval=60
last_copy_time=0

while true; do

    if [[ -n "$(pbpaste | tr -d '[:space:]')" ]]; then
        current_time=$(date +%s)
        if [ $last_copy_time -eq 0 ]; then
            last_copy_time=$current_time
        elif [ $((current_time - last_copy_time)) -ge $interval ]; then
            pbcopy </dev/null
            last_copy_time=0
        fi
    fi

    sleep 30
done
