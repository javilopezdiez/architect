#!/usr/bin/env bash

laptop_display="eDP-1"
scale=0.8
width=1920
height=1080

secondary_display="DP-1"
secondary_display1="DP-1-8"

res_map=(
	"HDMI-1:1920x1080"
	"HDMI-2:2560x1440"
	"DVI-I-1-1:1920x1080"
	"DP-1-8:3840x2160"
)

crop_name="CROPPED"

# 4k
full_w=3840
full_h=2160
crop_h=1820

# QHD
# full_w=2560
# full_h=1440
# crop_h=1240

wallpaper='/home/loncelot/Pictures/wallpapers/others/ubuntu6_06.png'

active_display=""

main() {
	local res=""

	if connected "$secondary_display"; then
		runSecondDisplay
	else
		if connected "$secondary_display1"; then
			secondary_display="$secondary_display1"
			runSecondDisplay
		else
			if xrandr --listmonitors | grep -qw "$crop_name"; then
				removeCropped
			fi
			res=$(loopSecondaries)
			if connected "$laptop_display"; then
				active_display=$laptop_display
				if [ -z "$res" ]; then
					toggleScaleLaptop
				else
					disconnectMain
				fi
			fi
		fi
	fi

	set_wallpaper "$res" "$active_display"
	xfdesktop --reload
	xfce4-panel --restart

	# carefull with exit
	# Leaving a note so that devilspie doesnt fuck the windows
	# os.execute("touch /tmp/devilspie_pause")
	# os.execute("sleep 3 && rm -f /tmp/devilspie_pause &")
}

runSecondDisplay() {
	disconnectMain
	toggleCropSecondDisplay
	res=$(get_resolution "$secondary_display")
	active_display=$secondary_display
}

toggleScaleLaptop() {
	if [ "$(get_scale "$laptop_display")" = "0.8" ]; then
		scale=1
	fi
	scaleLaptop
}
scaleLaptop() {
	xrandr --output "$laptop_display" \
		--primary \
		--mode "${width}x${height}" \
		--scale "${scale}x${scale}" \
		--pos 0x0 \
		--rotate normal
}

toggleCropSecondDisplay() {
	if xrandr --listmonitors | grep -qw "$crop_name"; then
		removeCropped
		xrandr --output "$secondary_display" \
			--primary \
			--fb ${full_w}x${full_h} \
			--mode ${full_w}x${full_h}
	else
		echo "Applying cropped monitor on $secondary_display..."
		xrandr --output "$secondary_display" \
			--primary \
			--fb ${full_w}x${crop_h} \
			--transform 1,0,0,0,1,0,0,0,1

		# xrandr --setmonitor "$crop_name" \
		# 	${full_w}/1016x${crop_h}/460+0+0 "$secondary_display"

		# 2560 × 1240 is full_w and full_h, crop_h is 1240
		xrandr --setmonitor "$crop_name" \
			${full_w}/597x${crop_h}/282+0+0 "$secondary_display"

	fi
	sleep 0.3
	xfwm4 --replace &
	sleep 0.5
}

removeCropped() {
	echo "Reverting $secondary_display to full screen..."
	xrandr --delmonitor "$crop_name"
}

loopSecondaries() {
	for entry in "${res_map[@]}"; do
		local output="${entry%%:*}"
		local resolution="${entry##*:}"
		if connected "$output"; then
			echo "Detected $output connected → setting mode $resolution..."
			xrandr --output "$output" \
				--primary \
				--mode "$resolution" \
				--pos 0x0 \
				--rotate normal
			active_display=$output
			echo "$resolution"
			return
		fi
	done
	echo ""
}

set_wallpaper() {
	local res="$1"
	active_display="/backdrop/screen0/monitor$2"
	# external app
	if [[ -n "$res" ]]; then
		feh --bg-scale "$wallpaper" --geometry "$res"
	else
		feh --bg-scale "$wallpaper"
	fi
	# all props
	for prop in $(xfconf-query -c xfce4-desktop -l | grep last-image); do
		xfconf-query -c xfce4-desktop -p "$prop" -s "$wallpaper"
	done
	# active display
	xfconf-query -c xfce4-desktop -p "$active_display/image-path" -s "$wallpaper" --create -t string
	xfconf-query -c xfce4-desktop -p "$active_display/last-image" -s "$wallpaper" --create -t string
	# loop workspaces
	total_workspaces=$(xfconf-query -c xfwm4 -p /general/workspace_count 2>/dev/null)
	echo "$total_workspaces workspaces active"
	for i in $(seq 0 $((total_workspaces-1))); do
		key="$active_display/workspace$i/last-image"
		xfconf-query -c xfce4-desktop -p "$key" -s "$wallpaper" --create -t string
	done
	# rearrange icons
	xfdesktop -A
	# change lockscreen
	sudo cp "$wallpaper" /usr/share/backgrounds/my-lockscreen.jpeg
}

connected() {
	local output="$1"
	xrandr --query | grep -qw "${output} connected"
}

get_resolution() {
	local display="$1"
	xrandr --query | grep "$display" | grep ' connected' | awk '{print $3}' | cut -d'+' -f1
}
get_resolution2() {
    local display="$1"
    xrandr --query |
        awk -v d="$display" '
            $0 ~ "^" d" " && $0 ~ / connected/ {
                if (match($0, /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/)) {
                    split(substr($0, RSTART, RLENGTH), a, "+")
                    print a[1]   # prints only WIDTHxHEIGHT
                }
            }'
}

get_scale() {
    local display="$1"
    xrandr --verbose | grep -A20 "^$display" | grep 'Transform:' | head -n1 | \
        sed -E 's/.*Transform:[[:space:]]*([0-9]+\.[0-9]+).*/\1/' | \
        awk '{printf "%.1f\n", $1}' # round 1 decimal
}

disconnectMain() {
	xrandr --output "$laptop_display" --off
}

main
