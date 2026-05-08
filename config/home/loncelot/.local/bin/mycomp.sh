#!/bin/bash

PICOM_CONF="$HOME/.config/picom/picom.conf"

if pgrep picom > /dev/null; then
    pkill picom
    xfconf-query -c xfwm4 -p /general/use_compositing -s true
else
    xfconf-query -c xfwm4 -p /general/use_compositing -s false
    picom --config "$PICOM_CONF" -b >/dev/null 2>&1 &
fi