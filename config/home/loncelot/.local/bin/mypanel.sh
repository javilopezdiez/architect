#!/bin/bash

PROP="/panels/panel-0/autohide-behavior"

current=$(xfconf-query -c xfce4-panel -p "$PROP")

if [ "$current" -eq 0 ]; then
    xfconf-query -c xfwm4 -p /general/margin_top -s 10
    xfconf-query -c xfce4-panel -p "$PROP" -s 2
else
    xfconf-query -c xfwm4 -p /general/margin_top -s 30
    xfconf-query -c xfce4-panel -p "$PROP" -s 0
fi