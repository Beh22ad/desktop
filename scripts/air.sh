#!/bin/bash

temp_file="/tmp/api-air.txt"

# Check if the file exists
if [ ! -f "$temp_file" ]; then
    touch "$temp_file"
fi

# Fetch JSON data using curl
json_data=$(curl 'https://mapq.waqi.info/mapq/nearest?from=10787' \
  -H 'accept: */*' \
  -H 'accept-language: en-US,en;q=0.9,fa;q=0.8,ur;q=0.7' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -H 'dnt: 1' \
  -H 'origin: https://aqicn.org' \
  -H 'priority: u=1, i' \
  -H 'referer: https://aqicn.org/' \
  -H 'sec-ch-ua: "Not)A;Brand";v="99", "Google Chrome";v="127", "Chromium";v="127"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: cross-site' \
  -H 'sec-gpc: 1' \
  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36' \
  --data-raw 'key=_2Y2EZVB5mOxIfMy8KSCJWXmtjaEE+Az8UFmgrZg==&token=na&uid=kIQid1722081843857&rqc=2'
)

# Extract the value using jq from the JSON data
value=$(echo "$json_data" | jq -r '.d[0].v')

if [ -n "$value" ]; then
    if [ "$value" -gt 100 ]; then
        o="$value 😷️"
    else
        o="$value 🥰️"
    fi
    echo "$o" > "$temp_file"
else
    o=$(cat "$temp_file")
fi

printf "%s\n" "$o"

