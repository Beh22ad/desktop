#!/bin/bash

RX=$(($(cat /sys/class/net/wlp2s0/statistics/rx_bytes)/1024/1024))
TX=$(($(cat /sys/class/net/wlp2s0/statistics/tx_bytes)/1024/1024))
SUM=$((RX+TX))

printf "<txt><span weight='normal' fgcolor='White' bgcolor='#850B02' gravity='east' size='medium' allow_breaks='true' line_height='1.1'  >  $SUM<sub>M</sub>  </span></txt>"
printf "<tool>$RX MB \n$TX MB</tool>"


#printf "%d MB\n%d MB\n"  $(( $(cat /sys/class/net/wlp2s0/statistics/rx_bytes) / 1024 / 1024 + 5 )) $(( $(cat /sys/class/net/wlp2s0/statistics/tx_bytes) / 1024 / 1024 ))
