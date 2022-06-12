#!/usr/bin/env sh

print_usage() {
    echo "USAGE:"
    echo "  $0 <limit>\n"
    echo "<limit> - Seconds to wait before killing Keyboard Cleaner"
}

get_uptime() {
    elapsed_time=$(echo $(ps -p $1 -o etime) | awk '{split($0, a, " "); print a[2]}')

    minutes=$(echo $elapsed_time | awk '{split($0, a, ":"); print a[1]}')
    seconds=$(echo $elapsed_time | awk '{split($0, a, ":"); print a[2]}')

    echo $((${minutes##0} * 60 + ${seconds##0}))
}

if ! [[ $1 =~ ^[0-9]+$ ]]; then
    print_usage
    exit 1
fi

while true; do
    pid=$(pgrep keyboard-cleaner)

    if [ "$pid" = "" ]; then
        echo "Keyboard Cleaner is not open!"
    else
        uptime=$(get_uptime $pid)

        if [ $uptime -gt $1 ]; then
            kill -9 $pid
            echo "Killed Keyboard Cleaner for exceeding the time limit!"
        else
            echo "Keyboard Cleaner is open but has not reached the time limit..."
        fi
    fi

    sleep 2
done
