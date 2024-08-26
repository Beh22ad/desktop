#!/bin/bash

temp_file="/tmp/api-fa2.txt"

# Check if the file exists
if [ ! -f "$temp_file" ]; then
    touch "$temp_file"
fi

# URL of the page to fetch
url="https://irimo.ir/far/wd/701-%D9%BE%DB%8C%D8%B4-%D8%A8%DB%8C%D9%86%DB%8C-%D9%88%D8%B6%D8%B9-%D9%87%D9%88%D8%A7%DB%8C-%D8%AA%D9%87%D8%B1%D8%A7%D9%86.html?id=17561"

# Fetch the HTML content using curl with the necessary cipher option
html_content=$(curl --ciphers 'DEFAULT:!DH' -s "$url")

# Check if the curl command was successful
if [ $? -eq 0 ] && [ -n "$html_content" ]; then
    # Extract the temperature using grep and sed, then remove the ° and c
    temperature=$(echo "$html_content" | grep -oP '(?<=<div align="center" class="" style="font-size:48px;direction:ltr">)[^<]+' | sed 's/°.*//')

    # If temperature was successfully extracted, update the temp_file
    if [ -n "$temperature" ]; then
        echo "$temperature" > "$temp_file"
    else
        # Use the previous temperature if extraction failed
        temperature=$(cat "$temp_file")
    fi
else
    # Use the previous temperature if curl failed
    temperature=$(cat "$temp_file")
fi

# Print the extracted temperature with the degree symbol
echo "$temperature°🌡️"
