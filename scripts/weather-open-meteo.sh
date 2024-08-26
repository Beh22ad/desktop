#!/bin/bash


temp_file="/tmp/api2.txt"

# Check if the file exists
if [ ! -f "$temp_file" ]; then
    touch "$temp_file"
fi

GAS_URL="https://script.google.com/macros/s/AKfycbyGxqz6AdqlPleeLeol6lEv2cVMrMEAQ0NUdPY7kMSfhL-W_0C0lKbLEqtR_XfPAiMAnQ/exec"

# Make the cURL request to your Google Apps Script
TEMPERATURE=$(curl "$GAS_URL")

if [ -n "$TEMPERATURE" ]; then
    o=$(echo "$TEMPERATURE" | tail -n 1)
    echo "$o" > "$temp_file"
else
    o=$(cat "$temp_file")
fi

printf "$o°C\n"
