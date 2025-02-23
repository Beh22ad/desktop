#!/usr/bin/env bash

# Starts a scan of available broadcasting SSIDs
# nmcli dev wifi rescan
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FIELDS=SSID,SECURITY
POSITION=0
YOFF=0
XOFF=0
FONT="DejaVu Sans Mono 12"

# Load configuration if available
if [ -r "$DIR/config" ]; then
    source "$DIR/config"
elif [ -r "$HOME/.config/rofi/wifi" ]; then
    source "$HOME/.config/rofi/wifi"
else
    echo "WARNING: config file not found! Using default values."
fi

# Always use the specified theme file
THEME_FILE="$HOME/.config/rofi/themes/power.rasi"

LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d')

# Dynamically calculate the width of the rofi menu
RWIDTH=$(($(echo "$LIST" | head -n 1 | awk '{print length($0); }') + 2))

# Dynamically change the height of the rofi menu
LINENUM=$(echo "$LIST" | wc -l)

# List of known connections for parsing later
KNOWNCON=$(nmcli connection show)

# Check if there is an active connection
CONSTATE=$(nmcli -fields WIFI g)
CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')
if [[ ! -z $CURRSSID ]]; then
    HIGHLINE=$(echo "$(echo "$LIST" | awk -F "[  ]{2,}" '{print $1}' | grep -Fx -m 1 "$CURRSSID")" | awk '{print NR}')
fi

# Adjust the number of lines based on the Wi-Fi state
if [ "$LINENUM" -gt 8 ] && [[ "$CONSTATE" =~ "enabled" ]]; then
    LINENUM=8
elif [[ "$CONSTATE" =~ "disabled" ]]; then
    LINENUM=1
fi

# Determine the toggle option (on/off)
if [[ "$CONSTATE" =~ "enabled" ]]; then
    TOGGLE="toggle off"
elif [[ "$CONSTATE" =~ "disabled" ]]; then
    TOGGLE="toggle on"
fi

# Run Rofi with the specified theme
CHENTRY=$(echo -e "$TOGGLE\nmanual\n$LIST" | uniq -u | \
    rofi -dmenu \
         -p "Wi-Fi SSID: " \
         -lines "$LINENUM" \
         -a "$HIGHLINE" \
         -location "$POSITION" \
         -yoffset "$YOFF" \
         -xoffset "$XOFF" \
         -font "$FONT" \
         -width -"$RWIDTH" \
         -theme "$THEME_FILE")

# Exit if no selection was made
if [ -z "$CHENTRY" ]; then
    exit 0
fi

CHSSID=$(echo "$CHENTRY" | sed 's/\s\{2,\}/|/g' | awk -F "|" '{print $1}')

# Handle manual entry or toggle options
if [ "$CHENTRY" = "manual" ]; then
    # Manual entry of SSID and password
    MSSID=$(echo "enter the SSID of the network (SSID,password)" | \
        rofi -dmenu -p "Manual Entry: " -font "$FONT" -lines 1 -theme "$THEME_FILE")
    MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')
    if [ -z "$MPASS" ]; then
        nmcli dev wifi con "$MSSID"
    else
        nmcli dev wifi con "$MSSID" password "$MPASS"
    fi
elif [ "$CHENTRY" = "toggle on" ]; then
    nmcli radio wifi on
elif [ "$CHENTRY" = "toggle off" ]; then
    nmcli radio wifi off
else
    # Handle preconfigured connections
    if [ "$CHSSID" = "*" ]; then
        CHSSID=$(echo "$CHENTRY" | sed 's/\s\{2,\}/|/g' | awk -F "|" '{print $3}')
    fi

    # Ensure CHSSID is not empty
    if [ -z "$CHSSID" ]; then
        notify-send "No SSID selected"
        exit 0
    fi

    # Check if the connection is already known
    if [[ $(echo "$KNOWNCON" | grep -w "$CHSSID") ]]; then
        # Attempt to connect using the stored credentials
        if nmcli con up "$CHSSID" &>/dev/null; then
            notify-send "Connected to $CHSSID"
        else
            # If connection fails, prompt for password
            WIFIPASS=$(rofi -dmenu -p "Password for $CHSSID: " -lines 1 -font "$FONT" -theme "$THEME_FILE")
            if [ -n "$WIFIPASS" ]; then
                if nmcli dev wifi con "$CHSSID" password "$WIFIPASS"; then
                    notify-send "Connected to $CHSSID"
                else
                    notify-send "Failed to connect to $CHSSID"
                fi
            fi
        fi
    else
        # For new connections, check if security is enabled
        if [[ "$CHENTRY" =~ "WPA2" ]] || [[ "$CHENTRY" =~ "WEP" ]]; then
            WIFIPASS=$(rofi -dmenu -p "Password for $CHSSID: " -lines 1 -font "$FONT" -theme "$THEME_FILE")
            if [ -n "$WIFIPASS" ]; then
                if nmcli dev wifi con "$CHSSID" password "$WIFIPASS"; then
                    notify-send "Connected to $CHSSID"
                else
                    notify-send "Failed to connect to $CHSSID"
                fi
            fi
        else
            # No security, connect directly
            if nmcli dev wifi con "$CHSSID"; then
                notify-send "Connected to $CHSSID"
            else
                notify-send "Failed to connect to $CHSSID"
            fi
        fi
    fi
fi
