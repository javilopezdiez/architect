#!/bin/bash


is_thinkpad() {
	xinput list --name-only | grep -Fqi "xy_3dg12 xy_3dg12 USB RF Adapter"
}

is_macbook12() {
	xinput list --name-only | grep -Fxq "Apple SPI Keyboard"
}

setuplayout() {
	if is_thinkpad; then
		setuplayoutThinkpad
	elif is_macbook12; then
		echo "macbook"
		setuplayoutMacbook12
	else
		setupKeysMacbook11
	fi
}
setuplayoutThinkpad() {
	setxkbmap -layout es,gb
	xmodmap ~/.Xmodmap # <>
	# /etc/keyd/xy_3dg12.conf
}
setuplayoutMacbook12() {
	setxkbmap -layout es,gb -variant mac
	echo 1 | sudo tee /sys/module/applespi/parameters/fnremap
	# /etc/keyd/macbook12.conf
}
setupKeysMacbook11() {
	echo "1" | sudo tee /sys/module/hid_apple/parameters/swap_fn_leftctrl
	echo "1" | sudo tee /sys/module/hid_apple/parameters/swap_opt_cmd
	echo "1" | sudo tee /sys/module/hid_apple/parameters/iso_layout
}

# setupKeysMacbook12() {
#     echo 1 | sudo tee /sys/module/applespi/parameters/fnremap
#     setxkbmap -option altwin:swap_lalt_lwin
#     setxkbmap -option altwin:swap_ralt_rwin
#     echo 1 | sudo tee /sys/module/applespi/parameters/iso_layout
#     xinput set-prop "Apple SPI Touchpad" "libinput Disable While Typing Enabled" 1
#     xinput set-prop "Apple SPI Touchpad" "libinput Tapping Enabled" 1
#     xinput set-prop "PalmReject Virtual Touchpad" "libinput Tapping Enabled" 1
# }

toggleTrackpadThinkpad() {
	TRACKPAD_ID=$(xinput list | grep -i "synaptics" | grep -o 'id=[0-9]*' | cut -d= -f2)

	if [ -n "$TRACKPAD_ID" ]; then
		echo "$TRACKPAD_ID"
		xinput disable "$TRACKPAD_ID"
	else
		echo "Trackpad not found"
	fi
}

toggleTrackpadMacbook() {
	TRACKPAD="Apple SPI Touchpad"
	if xinput list-props "$TRACKPAD" | grep -q "Device Enabled.*1$"; then
		echo "Disabling trackpad"
		xinput disable "$TRACKPAD"
	else
		echo "Enabling trackpad"
		xinput enable "$TRACKPAD"
		# (
		#     sleep 300 # seconds
		#     xinput disable "$TRACKPAD"
		#     echo "Trackpad automatically disabled"
		# ) &
	fi
}

toggle12Palm4GamesMacbook12() {
	DEVICE="Apple SPI Touchpad"
	DWT_PROP="libinput Disable While Typing Enabled"
	TAP_PROP="libinput Tapping Enabled"
	CLICK_PROP="libinput Click Method Enabled"

	VALUE=$(xinput list-props "$DEVICE" |
		grep -i "$DWT_PROP" |
		head -n 1 |
		sed -E 's/.*:[[:space:]]*([01]).*/\1/')

	if [ "$VALUE" = "1" ]; then
		xinput set-prop "$DEVICE" "$DWT_PROP" 0
		echo "DisableWhileTyping: OFF"
		xinput set-prop "$DEVICE" "$TAP_PROP" 0
		echo "TappingEnabled: OFF"
		xinput set-prop "$DEVICE" "$CLICK_PROP" 1 0
		echo "ClickingEnabled: ON"
	elif [ "$VALUE" = "0" ]; then
		xinput set-prop "$DEVICE" "$DWT_PROP" 1
		echo "DisableWhileTyping: ON"
		xinput set-prop "$DEVICE" "$TAP_PROP" 1
		echo "TappingEnabled: ON"
		xinput set-prop "$DEVICE" "$CLICK_PROP" 0 1
		echo "ClickingEnabled: OFF"
	else
		echo "Could not determine current DisableWhileTyping state."
		echo "Detected value: '$VALUE'"
		return 1
	fi
	# Toggle compositor
	mycomp.sh
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
	--setup)
		setuplayout
		;;
	--toggleLayout)
		toggleLayout
		;;
	--toggleTrackpad)
		toggleTrackpadThinkpad
		toggleTrackpadMacbook
		;;
	--togglePalm)
		toggle12Palm4GamesMacbook12
		;;
	--toggleSound)
		toggleMechanicalSound
		;;
	--toggleClick)
		toggleClick
		;;
	*)
		echo "Usage: $0 {--setup|--toggleSound|--toggleLayout|--toggleClick}"
		exit 1
		;;
esac
