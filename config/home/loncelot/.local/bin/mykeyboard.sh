#!/bin/bash

setupLaout() {
    setxkbmap -layout es,gb
    # mac keyboard
        # setxkbmap -layout es,gb -variant mac
        # setxkbmap -option grp:win_space_toggle
    # japaneese keyboard
        xmodmap ~/.Xmodmap
        # xkbcomp ${HOME}/.config/mylayout.xkb $DISPLAY
        # sudo systemd-hwdb update
        # sudo udevadm trigger --subsystem-match=input --action=change
}

setupKeys() {
    echo "1" | sudo tee /sys/module/hid_apple/parameters/swap_fn_leftctrl
    echo "1" | sudo tee /sys/module/hid_apple/parameters/swap_opt_cmd
    echo "1" | sudo tee /sys/module/hid_apple/parameters/iso_layout
}

setupTrackpad() {
    # Either x230
    # xinput set-prop "bcm5974" "libinput Tapping Enabled" 1
    # Disable x270
    TRACKPAD_ID=$(xinput list | grep -i "synaptics" | awk '{print $6}' | sed 's/id=//')
    if [ -n "$TRACKPAD_ID" ]; then
        xinput disable "$TRACKPAD_ID"
    fi
}

rightExternalTrackpad() {
    xinput set-prop "AppleMagicTrackpad" "Coordinate Transformation Matrix" 0 -1 0 1 0 -1 0 0 1
    enableExternalTrackpad
}

invertExternalTrackpad() {
    xinput set-prop "AppleMagicTrackpad" "Coordinate Transformation Matrix" -1 0 1 0 -1 1 0 0 1
    enableExternalTrackpad
}

enableExternalTrackpad() {
    xinput set-prop "AppleMagicTrackpad" "libinput Tapping Enabled" 1
    xinput set-prop "AppleMagicTrackpad" "libinput Natural Scrolling Enabled" 0
    xinput set-prop "AppleMagicTrackpad" "libinput Accel Speed" 0.2
}

toggleMechanicalSound() {

    # pgrep -a mech
    # ps -ef | grep mech
    # ps -C mechvibes
    # ps -f 13694 # full but not necessary
    process=$(pgrep -x "mechvibes")
    if [ -n "$process" ]; then
        killall mechvibes
        killall mechvibes
    else
        mechvibes & sleep 2
        mywin.sh --close "Mechvibes"
    fi
}
toggleClick() {
    process=$(pgrep -x "clicksound")
    if [ -n "$process" ]; then
        # kill $(pgrep clicksound) dunno if this would work
        sudo killall clicksound
    else
        echo "ok"
        sudo ${HOME}/.local/bin/myclick/clicksound \
            ${HOME}/.local/bin/myclick/sounds/single.mp3 \
            ${HOME}/.local/bin/myclick/sounds/mechsoft1.mp3 \
            ${USER} \
            >/dev/null 2>&1 &
    fi
}

toggleLayout() {
    layout=$(setxkbmap -query | grep layout | awk '{print $2}')
    if [ "$layout" = "es" ];
    then
        setxkbmap gb
    else
        setxkbmap es
    fi
}

case "$1" in
    --trackpad)
        invertExternalTrackpad
        ;;
    --setup)
        setupLaout
        # setupKeys
        setupTrackpad
        ;;
    --toggleSound)
        toggleMechanicalSound
        ;;
    --toggleLayout)
        toggleLayout
        ;;
    --toggleClick)
        # pgrep -a click TODO, TOO MANY PROCESS
        toggleClick
        ;;
    *)
        echo "Usage: $0 {--setup|--toggleSound|--toggleLayout|--toggleClick}"
        exit 1
        ;;
esac