#!/bin/bash

RX=$(($(cat /sys/class/net/wlp2s0/statistics/rx_bytes)/1024/1024))
TX=$(($(cat /sys/class/net/wlp2s0/statistics/tx_bytes)/1024/1024))


printf "<txt>$((RX+TX))\n🔺🔻️</txt>"
printf "<tool>$RX MB \n$TX MB</tool>"


#printf "%d MB\n%d MB\n"  $(( $(cat /sys/class/net/wlp2s0/statistics/rx_bytes) / 1024 / 1024 + 5 )) $(( $(cat /sys/class/net/wlp2s0/statistics/tx_bytes) / 1024 / 1024 ))
