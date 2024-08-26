#!/bin/bash
Day=$(jdate +%W |xargs  basename)
printf "<tool>$Day $(jdate +%V%n%n%W)</tool>"
printf "<txt>$(jdate +%G)\n$Day $(jdate +%v)</txt>"
printf "<tool>$RX MB \n$TX MB</tool><txtclick>xbacklight -set 0</txtclick>"


#echo "$(jdate +%G)";echo "$(jdate +%W |xargs  basename) $(jdate +%v)";



