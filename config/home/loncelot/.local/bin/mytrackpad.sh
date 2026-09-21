#!/bin/bash

TOUCHPAD="7"
KEYBOARD="6"
DELAY="0.8"

timer_pid=""

enable_touchpad() {
    xinput enable "$TOUCHPAD"
}

disable_touchpad() {
    xinput disable "$TOUCHPAD"
}

cleanup() {
    [ -n "$timer_pid" ] && kill "$timer_pid" 2>/dev/null
    enable_touchpad
    exit 0
}

trap cleanup INT TERM EXIT

enable_touchpad

xinput test "$KEYBOARD" | while read -r event keycode; do
    if [ "$event" = "key" ] && [ "$keycode" = "press" ]; then
        disable_touchpad

        [ -n "$timer_pid" ] && kill "$timer_pid" 2>/dev/null

        (
            sleep "$DELAY"
            enable_touchpad
        ) &

        timer_pid=$!
    fi
done