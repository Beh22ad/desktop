#!/bin/bash

# Check if Caps Lock is on
if xset -q | grep "Caps Lock:   on"; then
    # Turn Caps Lock off
    xdotool key Caps_Lock
fi
