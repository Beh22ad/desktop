#!/bin/bash
# Break Reminder Widget for XFCE Panel (Generic Monitor)
#
# Usage:
#   To run the daemon (which keeps track of time and notifications):
#       ./break_reminder.sh daemon &
#
#   To output the current icon (for your panel plugin):
#       ./break_reminder.sh
#
#   To manually toggle pause/resume (assign this to a click action):
#       ./break_reminder.sh toggle
#
# Requirements: xdotool, xprop, notify-send, paplay

# Configuration
BREAK_TIME=1200             # Break interval (20 minutes)
THANK_TIME=20               # Thank you interval (20 seconds)
BREAK_TITLE="Break Time"
BREAK_MESSAGE="Take a break"
THANK_TITLE="Thank You"
THANK_MESSAGE="Thanks for taking a break"
SOUND_START="/usr/share/sounds/freedesktop/stereo/message-new-instant.oga"
SOUND_FILE="/usr/share/sounds/freedesktop/stereo/complete.oga"

# Icon definitions
ICON_ACTIVE="⏲"
ICON_PAUSED="⏸"

# State file location (used to share state between invocations)
STATEFILE="/tmp/break_reminder_state"

# Initialize the state file with defaults if it doesn't exist.
init_state() {
    cat <<EOF > "$STATEFILE"
active=1
paused=0
auto_paused=0
phase=break
timer_start=$(date +%s)
elapsed=0
EOF
}

# Read state from the state file.
read_state() {
    [ -f "$STATEFILE" ] || init_state
    source "$STATEFILE"
}

# Write state to the state file.
write_state() {
    cat <<EOF > "$STATEFILE"
active=$active
paused=$paused
auto_paused=$auto_paused
phase=$phase
timer_start=$timer_start
elapsed=$elapsed
EOF
}

# Toggle manual pause/resume.
toggle_pause() {
    read_state
    if [ "$paused" -eq 1 ]; then
        # Resume (manual unpause clears any auto-pause flag)
        paused=0
        auto_paused=0
        # Adjust timer start so that elapsed time is preserved
        timer_start=$(($(date +%s) - elapsed))
        notify-send "Break Reminder" "Timer resumed" --expire-time=2000
    else
        # Pause manually
        paused=1
        auto_paused=0
        elapsed=$(($(date +%s) - timer_start))
        notify-send "Break Reminder" "Timer paused" --expire-time=2000
    fi
    write_state
}

# Check if the currently active window is fullscreen.
check_fullscreen() {
    win=$(xdotool getactivewindow 2>/dev/null)
    [ -z "$win" ] && return 1
    state=$(xprop -id "$win" _NET_WM_STATE 2>/dev/null)
    echo "$state" | grep -qi "fullscreen"
    return $?
}

# Daemon mode: continuously update timer, send notifications, and auto-pause/resume.
if [ "$1" == "daemon" ]; then
    [ -f "$STATEFILE" ] || init_state

    while true; do
        read_state
        current=$(date +%s)
        if [ "$active" -eq 1 ] && [ "$paused" -eq 0 ]; then
            # If not already paused manually, check for fullscreen windows.
            if check_fullscreen; then
                paused=1
                auto_paused=1
                elapsed=$(($current - timer_start))
                notify-send "Break Reminder" "Timer paused (fullscreen)" --expire-time=2000
            fi
        elif [ "$paused" -eq 1 ] && [ "$auto_paused" -eq 1 ]; then
            # Auto-resume if fullscreen is no longer active.
            if ! check_fullscreen; then
                paused=0
                auto_paused=0
                timer_start=$(($current - elapsed))
                notify-send "Break Reminder" "Timer resumed (fullscreen ended)" --expire-time=2000
            fi
        fi

        if [ "$active" -eq 1 ] && [ "$paused" -eq 0 ]; then
            elapsed=$(($current - timer_start))
            if [ "$phase" == "break" ] && [ "$elapsed" -ge "$BREAK_TIME" ]; then
                # Time for a break notification.
                notify-send "$BREAK_TITLE" "$BREAK_MESSAGE" --urgency=critical --expire-time=0
                paplay "$SOUND_START"
                phase="thank"
                timer_start=$(date +%s)
                elapsed=0
            elif [ "$phase" == "thank" ] && [ "$elapsed" -ge "$THANK_TIME" ]; then
                # Thank you notification after break.
                notify-send "$THANK_TITLE" "$THANK_MESSAGE" --expire-time=5000
                paplay "$SOUND_FILE"
                phase="break"
                timer_start=$(date +%s)
                elapsed=0
            fi
        fi

        write_state
        sleep 1
    done
    exit 0
fi

# Manual toggle mode.
if [ "$1" == "toggle" ]; then
    toggle_pause
    exit 0
fi

# Default mode: output the current icon (for panel display).
if [ ! -f "$STATEFILE" ]; then
    init_state
fi
read_state
if [ "$paused" -eq 1 ]; then
    echo "$ICON_PAUSED"
else
    echo "$ICON_ACTIVE"
fi
