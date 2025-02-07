#!/bin/sh

if [ -z "$(xrandr --query | grep -w "connected")" ]; then
    xrandr --output eDP-1 \
        --primary \
        --mode 1366x768 \
        --pos 277x1080 \
        --rotate normal
elif [ "$1" = "--ontop" ]; then
    if [ -n "$(xrandr --query | grep -w "DP-1 connected")" ]; then
        xrandr --output DP-1 \
            --primary \
            --mode 1920x1080 \
            --pos 0x0 \
            --rotate normal \
            --output eDP-1 \
            --mode 1366x768 \
            --pos 277x1080 \
            --rotate normal
    elif [ -n "$(xrandr --query | grep -w "HDMI-1 connected")" ]; then
        xrandr --output HDMI-1 \
            --primary \
            --mode 1920x1080 \
            --pos 0x0 \
            --rotate normal \
            --output eDP-1 \
            --mode 1366x768 \
            --pos 277x1080 \
            --rotate normal
    fi
elif [ -n "$(xrandr --query | grep -w "DP-1 connected")" ]; then
    xrandr --output DP-1 \
        --primary \
        --mode 1920x1080 \
        --pos 0x0 \
        --rotate normal \
        --output eDP-1 --off
elif [ -n "$(xrandr --query | grep -w "HDMI-1 connected")" ]; then
    xrandr --output HDMI-1 \
        --primary \
        --mode 1920x1080 \
        --pos 0x0 \
        --rotate normal \
        --output eDP-1 --off
fi
