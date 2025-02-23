#!/bin/bash

# Define the options
OPTIONS="Logout\nSuspend\nReboot\nShutdown"

# Launch rofi with the options and custom theme
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Power Menu" -i -width 20 -lines 4 -theme ~/.config/rofi/themes/power.rasi)

# Execute the chosen action
case "$CHOICE" in
    "Logout")
        # Tell Awesome WM to exit cleanly
        awesome-client 'awesome.quit()'
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
    *)
        exit 0
        ;;
esac
