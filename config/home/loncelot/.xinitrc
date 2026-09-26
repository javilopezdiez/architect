#!/bin/bash


# Added by `hints --setup`
export ACCESSIBILITY_ENABLED=1
export GTK_MODULES=gail:atk-bridge
export OOO_FORCE_DESKTOP=gnome
export GNOME_ACCESSIBILITY=1
export QT_ACCESSIBILITY=1
export QT_LINUX_ACCESSIBILITY_ALWAYS_ON=1
exec dbus-run-session startxfce4