#!/bin/bash

# BAT0 info
B0=$(cat /sys/class/power_supply/BAT0/capacity)
S0=$(cat /sys/class/power_supply/BAT0/status)
TIME0=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'time to' | awk -F: '{print $2}' | xargs)

# BAT1 info
B1=$(cat /sys/class/power_supply/BAT1/capacity)
S1=$(cat /sys/class/power_supply/BAT1/status)
TIME1=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep -E 'time to' | awk -F: '{print $2}' | xargs)

# Output for Genmon (plain text)
echo "EXT: $B1% $S1 ($TIME1) | INT: $B0% $S0 ($TIME0)"
