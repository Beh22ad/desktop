#!/bin/bash

# Call the other script and capture its output
output=$(/home/b/D/setup/linux/user/scripts/xfce-date.sh s)
tdate=$(date +"%H:%M")

#echo "$(date +"%H:%M")"
printf "<txt><span weight='normal' fgcolor='White' bgcolor='#144951' gravity='east' size='medium'  >    $output    </span>\n<span weight='normal' fgcolor='White' bgcolor='#241F31' gravity='east'  >$tdate</span></txt>"

printf "<tool>$(date +%Y-%-m-%d) [$(date +%B)]\n۱۴۰۴/$output</tool>"
