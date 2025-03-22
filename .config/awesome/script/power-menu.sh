#!/bin/bash
# Define the options
OPTIONS="Logout\nSuspend\nReboot\nShutdown"
# Launch rofi with the options and custom theme
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Good bye!" -i -width 15 -lines 4 \
    -theme ~/.config/rofi/themes/power.rasi \
    -location 1 \
    -yoffset 28 \
    -font "Sans 14" \
    -theme-str "window { width: 20ch; } listview { lines: 4; } textbox-prompt-colon { enabled: false; } entry { enabled: false; } "
    )
# Execute the chosen action
case "$CHOICE" in
    "Logout")
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
