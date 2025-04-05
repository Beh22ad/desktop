#!/bin/bash

# Call the other script and capture its output
output=$(/home/b/D/setup/linux/user/scripts/xfce-date.sh s)
#tdate=$(date +"%H:%M")
#bgcolor='#144951'  gravity='east'
#echo "$(date +"%H:%M")"
printf "<txt><span weight='normal' fgcolor='White'  size='medium'  line_height='1'  > ۱۴۰۴/$output </span></txt>"

printf "<tool>$(date +%Y-%-m-%d) [$(date +%B)]\n۱۴۰۴/$output</tool>"
