#!/bin/bash

MOUNT_POINT=~/mnt/sda1
SERVER="//192.168.1.1/sda1"
USER="Admin-USB"

mkdir -p "$MOUNT_POINT"
echo sudo mount -t cifs "$SERVER" "$MOUNT_POINT" -o username="$USER"
sudo mount -t cifs "$SERVER" "$MOUNT_POINT" -o username="$USER" && xfce4-terminal --working-directory="$MOUNT_POINT"