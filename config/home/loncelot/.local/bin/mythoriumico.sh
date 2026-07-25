#!/usr/bin/env bash

IGNORE_TITLES=(
    "Picture in picture"
    "spotify_player"
    "yt-x"
)

is_ignored() {
    local title="$1"

    for ignored in "${IGNORE_TITLES[@]}"; do
        if [[ "$title" == "$ignored" ]]; then
            return 0
        fi
    done

    return 1
}

LAST=""

xprop -spy -root _NET_ACTIVE_WINDOW | while read -r line; do
    WIN_ID=$(xdotool getactivewindow 2>/dev/null)
    TITLE=$(xdotool getwindowname "$WIN_ID" 2>/dev/null)

    if [ -n "$TITLE" ] && [ "$TITLE" != "$LAST" ]; then
        if ! is_ignored "$TITLE"; then
            lua "$HOME/.local/bin/mythoriumico.lua"
        fi
        LAST="$TITLE"
    fi
done