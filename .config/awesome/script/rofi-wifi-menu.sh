#!/usr/bin/env bash

# Starts a scan of available broadcasting SSIDs
nmcli dev wifi rescan

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FIELDS=SSID,SECURITY
POSITION=0
YOFF=0
XOFF=0
FONT="DejaVu Sans Mono 20"

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

# Get the list and remove the header line (first line) and separator line
LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '1d;/^--/d')

# Dynamically calculate the width of the rofi menu
RWIDTH=$(($(echo "$LIST" | head -n 1 | awk '{print length($0); }') + 6))

# Dynamically change the height of the rofi menu
LINENUM=$(($(echo "$LIST" | wc -l) + 100))

# List of known connections for parsing later
KNOWNCON=$(nmcli connection show)

# Check if there is an active connection
CONSTATE=$(nmcli -fields WIFI g)
CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')
if [[ ! -z $CURRSSID ]]; then
    HIGHLINE=$(echo "$(echo "$LIST" | awk -F "[ ]{2,}" '{print $1}' | grep -Fx -m 1 "$CURRSSID")" | awk '{print NR}')
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

# Add "Disconnect from [Wi-Fi SSID]" option if connected to a network, with styling
if [ -n "$CURRSSID" ]; then
    # Use Rofi markup to style the "disconnect" option
    DISCONNECT_ENTRY="<span foreground='#f96c00' weight='bold' stretch='expanded'>Disconnect from $CURRSSID</span>"
    MENU_ENTRIES=$(echo -e "$DISCONNECT_ENTRY\n$LIST" | uniq -u)
else
    MENU_ENTRIES=$(echo -e "$LIST" | uniq -u)
fi

# Run Rofi with the specified theme and enable markup
CHENTRY=$(echo -e "$MENU_ENTRIES" | \
		 rofi -dmenu \
		 -p "  " \
		 -i \
         -lines "$LINENUM" \
         -markup-rows \
         -a "$HIGHLINE" \
         -location "$POSITION" \
         -yoffset "$YOFF" \
         -xoffset "$XOFF" \
         -font "$FONT" \
         -width -"$RWIDTH" \
         -theme "$THEME_FILE" \
         -theme-str "window { width: ${RWIDTH}ch; height: 55%; } listview { lines: ${LINENUM}; } textbox-prompt-colon { enabled: false; } entry { enabled: false; } "
         )

# Exit if no selection was made
if [ -z "$CHENTRY" ]; then
    exit 0
fi

# Remove markup tags from the selection
CHENTRY_CLEAN=$(echo "$CHENTRY" | sed -e 's/<[^>]*>//g')
CHSSID=$(echo "$CHENTRY_CLEAN" | sed 's/\s\{2,\}/|/g' | awk -F "|" '{print $1}')

# Handle "Disconnect from [Wi-Fi SSID]" option
if [ "$CHENTRY_CLEAN" = "Disconnect from $CURRSSID" ]; then
    if [ -n "$CURRSSID" ]; then
        nmcli connection down id "$CURRSSID"
        notify-send "WiFi" "Disconnected from $CURRSSID"
    else
        notify-send "WiFi" "No active Wi-Fi connection to disconnect."
    fi
    exit 0
fi

# Handle manual entry or toggle options (if needed)
# (Include any additional options here if you have them)

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
    if [[ "$CHENTRY_CLEAN" =~ "WPA2" ]] || [[ "$CHENTRY_CLEAN" =~ "WEP" ]]; then
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
