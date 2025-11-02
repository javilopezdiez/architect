# #!/bin/sh
if [ -n "$(xrandr --query | grep -w "HDMI-1 connected")" ]; then
    # xrandr --output HDMI-1 --mode 3840x2160-60
    xrandr --output HDMI-1 \
        --primary \
        --mode 1920x1080 \
        --pos 0x0 \
        --rotate normal \
        --output eDP-1 \
        --off
elif [ -n "$(xrandr --query | grep -w "HDMI-2 connected")" ]; then
    xrandr --output HDMI-2 \
        --primary \
        --mode 2560x1440 \
        --pos 0x0 \
        --rotate normal \
        --output eDP-1 \
        --off
elif [ -n "$(xrandr --query | grep -w "DVI-I-1-1 connected")" ]; then
    xrandr --output DVI-I-1-1 \
        --primary \
        --mode 1920x1080 \
        --pos 0x0 \
        --rotate normal \
        --output eDP-1 \
        --off
else
    SCALE=0.80
    res=$(xrandr | grep -w "eDP-1 connected" | grep -oP '\d+x\d+')
    # width=$(echo $res | cut -d'x' -f1)
    # height=$(echo $res | cut -d'x' -f2)
    width=1920
    height=1080
    new_width=$(awk "BEGIN {printf \"%d\", $width / $SCALE}")
    new_height=$(awk "BEGIN {printf \"%d\", $height / $SCALE}")
    xrandr --output eDP-1 \
           --mode ${width}x${height} \
           --scale ${SCALE}x${SCALE} \
           --pos 0x0 \
           --rotate normal
fi
# if [ -z "$(xrandr --query | grep -w "connected")" ]; then
#     xrandr --output eDP-1 \
#         --primary \
#         --mode 1366x768 \
#         --pos 277x1080 \
#         --rotate normal
# elif [ "$1" = "--ontop" ]; then
#     if [ -n "$(xrandr --query | grep -w "DP-1 connected")" ]; then
#         xrandr --output DP-1 \
#             --primary \
#             --mode 1920x1080 \
#             --pos 0x0 \
#             --rotate normal \
#             --output eDP-1 \
#             --mode 1366x768 \
#             --pos 277x1080 \
#             --rotate normal
#     elif [ -n "$(xrandr --query | grep -w "HDMI-1 connected")" ]; then
#         xrandr --output HDMI-1 \
#             --primary \
#             --mode 1920x1080 \
#             --pos 0x0 \
#             --rotate normal \
#             --output eDP-1 \
#             --mode 1366x768 \
#             --pos 277x1080 \
#             --rotate normal
#     fi
# elif [ -n "$(xrandr --query | grep -w "DP-1 connected")" ]; then
#     xrandr --output DP-1 \
#         --primary \
#         --mode 1920x1080 \
#         --pos 0x0 \
#         --rotate normal \
#         --output eDP-1 --off
# elif [ -n "$(xrandr --query | grep -w "HDMI-1 connected")" ]; then
#     xrandr --output HDMI-1 \
#         --primary \
#         --mode 1920x1080 \
#         --pos 0x0 \
#         --rotate normal \
#         --output eDP-1 --off
# fi
