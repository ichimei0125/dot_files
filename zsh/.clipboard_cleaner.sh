#!/bin/zsh

interval=60  # 剪贴板清空等待时间（秒）
last_copy_time=0

while true; do
    current_time=$(date +%s)

    # 直接判断剪贴板是否为空，不保存内容
    if pbpaste | grep -q '[^[:space:]]'; then
        # 剪贴板非空时记录当前时间
        last_copy_time=$current_time
    else
        # 剪贴板为空则无需处理
        last_copy_time=0
    fi

    # 检测是否超过 interval 时间
    if [ $last_copy_time -ne 0 ] && [ $((current_time - last_copy_time)) -ge $interval ]; then
        pbcopy </dev/null
        last_copy_time=0
    fi

    sleep 30
done
