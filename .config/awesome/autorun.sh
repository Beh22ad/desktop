#!/bin/bash

pkill picom
if ! pgrep -x "picom" > /dev/null; then
    picom --config ~/.config/picom.conf &
fi

syndaemon -i .5 -K -t -R -d &


setxkbmap -layout "us,ir" -option "grp:alt_shift_toggle" &

#if ! pgrep -x "nm-applet" > /dev/null; then
   # nm-applet &
#fi

if ! pgrep -x "pnmixer" > /dev/null; then
    pnmixer &
fi

if ! pgrep -x "copyq" > /dev/null; then
    copyq &
fi

if ! pgrep -x "redshift-gtk" > /dev/null; then
    redshift-gtk &
fi

if ! pgrep -x "xfce4-power-manager" > /dev/null; then
    xfce4-power-manager &
fi

pavucontrol &

#bluetooh keyboard
sleep 5
~/.config/awesome/script/bluetooth-keyboard.sh &

#disable Caps Lock key
setxkbmap -option ctrl:nocaps
