#!/usr/bin/env bash

LAST=""

xprop -spy -root _NET_ACTIVE_WINDOW | while read -r line; do
    WIN_ID=$(xdotool getactivewindow 2>/dev/null)
    TITLE=$(xdotool getwindowname "$WIN_ID" 2>/dev/null)

    if [ -n "$TITLE" ] && [ "$TITLE" != "$LAST" ]; then
        lua "$HOME/.local/bin/mythoriumico.lua"
        LAST="$TITLE"
    fi
done