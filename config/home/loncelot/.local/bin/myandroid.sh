#!/bin/bash

DEVICE_NAME="test1"
RUNNING=$(gmtool admin list --running | grep "$DEVICE_NAME")

if [ -n "$RUNNING" ]; then
    echo "Genymotion running -> stopping..."
    gmtool admin stop "$DEVICE_NAME"
    pkill -f VirtualBox
    pkill -f VBoxHeadless
    adb kill-server
    echo "Stopped everything."
else
    echo "Starting Genymotion..."
    adb start-server
    gmtool admin start "$DEVICE_NAME"
    adb wait-for-device
    echo "Device started."
fi