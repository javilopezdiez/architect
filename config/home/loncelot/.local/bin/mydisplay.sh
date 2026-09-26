#!/usr/bin/env bash

laptop_display="eDP-1"
res_map=(
    "eDP-1:1920x1200"
    "HDMI-1:1920x1080"
    "HDMI-2:2560x1440"
    "DVI-I-1-1:1920x1080"
    "DP-1:2560x1440"
    "DP-1-9:3840x2160"
)
wallpaper='/home/loncelot/Pictures/wallpapers/wpp.png'
active_display=""

main() {
    setDisplay
    set_wallpaper "$active_res" "$active_display"
    xfdesktop --reload
    xfce4-panel --restart
}

setDisplay() {
    local laptop_res=""
    active_display=""
    active_res=""

    for entry in "${res_map[@]}"; do
        local output="${entry%%:*}"
        local resolution="${entry##*:}"

        if [[ "$output" == "$laptop_display" ]]; then
            laptop_res="$resolution"
            continue
        fi

        if connected "$output"; then
            xrandr --output "$laptop_display" --off
            xrandr --output "$output" --primary --mode "$resolution" --pos 0x0 --rotate normal
            active_display="$output"
            active_res="$resolution"
            return
        fi
    done

    xrandr --output "$laptop_display" --primary --mode "$laptop_res" --pos 0x0 --rotate normal
    active_display="$laptop_display"
    active_res="$laptop_res"
}

set_wallpaper() {
    local res="$1"
    local display="$2"
    local monitor
    monitor=$(xfconf-query -c xfce4-desktop -l | grep -F "$display" | grep -m1 '/image-path$' | sed 's|/image-path$||')
    if [[ -n "$res" ]]; then
        feh --bg-scale "$wallpaper"
    fi
    for prop in $(xfconf-query -c xfce4-desktop -l | grep last-image); do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$wallpaper"
    done
    if [[ -n "$monitor" ]]; then
        xfconf-query -c xfce4-desktop -p "$monitor/image-path" -s "$wallpaper" --create -t string
        xfconf-query -c xfce4-desktop -p "$monitor/last-image" -s "$wallpaper" --create -t string
        total_workspaces=$(xfconf-query -c xfwm4 -p /general/workspace_count 2>/dev/null)
        for i in $(seq 0 $((total_workspaces-1))); do
            key="$monitor/workspace$i/last-image"
            xfconf-query -c xfce4-desktop -p "$key" -s "$wallpaper" --create -t string
        done
    fi
    xfdesktop -A
    sudo cp "$wallpaper" /usr/share/backgrounds/my-lockscreen.jpeg
}

connected() {
    xrandr --query | grep -qw "${1} connected"
}

main