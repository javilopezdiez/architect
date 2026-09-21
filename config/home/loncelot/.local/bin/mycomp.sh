#!/bin/bash

PICOM_CONF="$HOME/.config/picom/picom.conf"
PICOM_RUNTIME="$HOME/.config/picom/picom-runtime.conf"
DARKS_OPACITY=75

if pgrep -x picom > /dev/null; then
	pkill -x picom
	xfconf-query -c xfwm4 -p /general/use_compositing -s true
else
	xfconf-query -c xfwm4 -p /general/use_compositing -s false
	sed "s/@DARKS_OPACITY@/$DARKS_OPACITY/g" \
		"$PICOM_CONF" > "$PICOM_RUNTIME"
	picom --config "$PICOM_RUNTIME" -b >/dev/null 2>&1 &

fi
