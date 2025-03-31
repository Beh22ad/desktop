#!/bin/bash

if ! pgrep -x "sxhkd" > /dev/null; then
    sxhkd &
fi

if ! pgrep -f "caps-auto.sh" > /dev/null; then
    ~/D/setup/linux/user/scripts/caps-auto.sh &
fi

# Delay for 2 minutes (120 seconds)
sleep 120

if ! pgrep -x "safeeye" > /dev/null; then
    safeeye &
fi
