#!/bin/bash

current_workspace=$(wmctrl -d | grep '*' | awk '{print $1}') # not working

luaW() {
    window_id=$(xdotool getwindowfocus)
    lua $HOME/.config/devilspie2/fullscreen.lua "$window_id" $1
}

minimizeW() {
    if [ -z "$1" ]; then
        window_id=$(xdotool getwindowfocus)
    else
        window_id=$(wmctrl -lG | grep "$1" | awk '{print $1}')
    fi
    wmctrl -i -r "$window_id" -b add,hidden
}

maximizeW() {
    if [ -z "$1" ]; then
        window_id=$(xdotool getwindowfocus)
    else
        window_id=$(wmctrl -lG | grep "$1" | awk '{print $1}')
    fi
    wmctrl -i -r "$window_id" -b add,maximized_vert,maximized_horz
}

closeW() {
    window_id=$(wmctrl -lG | \
        grep "$1" | \
        grep -v 'wmctrl -l' | \
        awk '{print $1}')
    wmctrl -i -c "$window_id"
}

clickW() {
    xdotool search --name "$1" \
        mousemove --window %1 50 200 \
        click 1
}


toggleTopW() {
    if [ -z "$1" ]; then
        window_id=$(xdotool getwindowfocus)
    else
        window_id=$(wmctrl -lG | grep "$1" | awk '{print $1}')
    fi

    current_state=$(xprop -id "$window_id" | grep "_NET_WM_STATE_ABOVE")

    if [ -z "$current_state" ]; then
        wmctrl -i -r "$window_id" -b add,above
    else
        wmctrl -i -r "$window_id" -b remove,above
    fi
}

exe() {
    case "$1" in
    --lua)
        luaW "$2"
        ;;
    --min)
        minimizeW "$2"
        ;;
    --max)
        maximizeW "$2"
        ;;
    --close)
        closeW "$2"
        ;;
    --click)
        clickW "$2"
        ;;
    --top)
        toggleTopW "$2"
        ;;
    *)
        echo "Usage: $0 {--lua--min|--max|--close|--click|--top} \"windowname, all or nothing (current)\""
        exit 1
        ;;
    esac
}

exeAll() {
    window_ids=$(wmctrl -l | awk '{print $1}')
    for window_id in $window_ids; do
        exe "$1" "$window_id"
    done
}

if [ "$2" = "all" ]; then
    exeAll "$1"
else
    exe "$1" "$2"
fi
