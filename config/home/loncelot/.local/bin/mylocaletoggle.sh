#!/bin/bash

# Get the current timezone
current_timezone=$(timedatectl show --property=Timezone --value)

# Define the timezones
timezone_madrid="Europe/Madrid"
timezone_canary="Atlantic/Canary"

# Toggle between the timezones
if [ "$current_timezone" == "$timezone_madrid" ]; then
    echo "Switching to Canary Islands timezone..."
    sudo timedatectl set-timezone $timezone_canary
elif [ "$current_timezone" == "$timezone_canary" ]; then
    echo "Switching to Madrid timezone..."
    sudo timedatectl set-timezone $timezone_madrid
else
    echo "Current timezone is not recognized. It is: $current_timezone"
    echo "Switching to Madrid timezone by default..."
    sudo timedatectl set-timezone $timezone_madrid
fi

# Display the new timezone
new_timezone=$(timedatectl show --property=Timezone --value)
echo "Timezone switched to: $new_timezone"

xfce4-panel -r