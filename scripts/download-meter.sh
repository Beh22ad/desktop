#!/bin/bash


RX=$(($(cat /sys/class/net/wlan0/statistics/rx_bytes)/1024/1024+$1)) 
TX=$(($(cat /sys/class/net/wlan0/statistics/tx_bytes)/1024/1024)) 


printf "<txt>$((RX+TX)) MB</txt>"
printf "<tool>$RX MB \n$TX MB</tool><txtclick>xbacklight -set 0</txtclick>"
echo "<bar>$((((RX+TX)*100)/$2))</bar>"

