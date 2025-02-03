#!/bin/bash

# Function to toggle Wi-Fi
toggle_wifi() {
    # Check if NetworkManager service is running
    if ! systemctl is-active --quiet NetworkManager; then
        echo "NetworkManager is not running."
        exit 1
    fi
    
    # Check the current state of Wi-Fi
    wifi_status=$(nmcli radio wifi)
    
    if [ "$wifi_status" == "enabled" ]; then
        # nmcli radio wifi off
        echo "Wi-Fi disabled."
    elif [ "$wifi_status" == "disabled" ]; then
        # nmcli radio wifi on
        echo "Wi-Fi enabled."
    else
        echo "Error: Unable to determine Wi-Fi state."
        exit 1
    fi
}

# Call the function
toggle_wifi