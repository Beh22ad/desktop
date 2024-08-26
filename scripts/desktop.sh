#!/bin/bash

# Check if there are any visible windows
if wmctrl -l | grep -q '^[0-9a-fA-F]* *[0-9]* *[0-9a-fA-F]* *[0-9]* *.*$'; then
    # Hide all windows
    wmctrl -k on
else
    # Show all windows
    wmctrl -k off
fi
