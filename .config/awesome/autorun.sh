#!/bin/bash

# Check if picom is running, if not, start it
if ! pgrep -x "picom" > /dev/null; then
    picom --config ~/.config/picom.conf &
fi

# syndaemon doesn't need a check because it might have specific parameters that differ
syndaemon -i .5 -K -t -R -d &

# Set keyboard options (no check needed as these are not persistent processes)
setxkbmap -option ctrl:nocaps
setxkbmap -layout "us,ir" -option "grp:alt_shift_toggle" &

# Check if nm-applet is running, if not, start it
if ! pgrep -x "nm-applet" > /dev/null; then
    nm-applet &
fi

# Check if pnmixer is running, if not, start it
if ! pgrep -x "pnmixer" > /dev/null; then
    pnmixer &
fi

# Check if qtpad script is running, if not, start it
if ! pgrep -f "mother.py" > /dev/null; then
    python3 ~/.local/lib/python3.11/site-packages/qtpad/mother.py &
fi

# Check if xfce4-clipman is running, if not, start it
if ! pgrep -x "xfce4-clipman" > /dev/null; then
    xfce4-clipman &
fi

# Check if redshift-gtk is running, if not, start it
if ! pgrep -x "redshift-gtk" > /dev/null; then
    redshift-gtk &
fi

# Check if safeeyes is running, if not, start it
if ! pgrep -x "safeeyes" > /dev/null; then
    safeeyes &
fi
