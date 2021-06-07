#!/usr/bin/env sh

print_usage() {
    echo "USAGE:"
    echo "  ./auto-kill.sh <limit>\n"
    echo "<limit> - Seconds to wait before killing KeyboardCleaner (number)"
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
    pid=$(pgrep KeyboardCleaner)

    if [ "$pid" = "" ]; then
        echo "KeyboardCleaner is not open!"
    else
        uptime=$(get_uptime $pid)

        if [ $uptime -gt $1 ]; then
            kill -9 $pid
            echo "Killed KeyboardCleaner for exceeding the time limit!"
        else
            echo "KeyboardCleaner is open but has not reached the time limit..."
        fi
    fi
    sleep 2
done
