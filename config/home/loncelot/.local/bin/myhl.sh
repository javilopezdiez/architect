#!/bin/bash

# Xvfb :2 -screen 0 1920x1080x24 &

# Xephyr -once -screen Xephyr -once -screen 2540x1190 :2 &
Xephyr -screen 2540x1190 :2 -ac -br -noreset -nolisten tcp -fp /usr/share/fonts/X11/misc &
# wmctrl -r Xephyr -e 0,-1920,0,1920,1080

sleep 1
x11vnc -localhost -display :2 -scale 2540x1190:nb -repeat &
DISPLAY=:2 steam -silent -offline -applaunch 70 &
x0vncserver -display :0 -rfbport 5900 -rfbauth ~/.vnc/passwd &