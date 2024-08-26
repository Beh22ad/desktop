#!/bin/bash
#Day=$(jdate +%W |xargs  basename)
#printf "<tool>$Day $(jdate +%V%n%n%W)</tool>"
#printf "<txt>$(jdate +%G)\n$Day $(jdate +%v)</txt>"
#temp_file="/home/Maya/.config/api.txt"

temp_file="/tmp/api.txt"

# Check if the file exists
if [ ! -f "$temp_file" ]; then
    touch "$temp_file"
fi

# Make the cURL request
JSON_OUTPUT=$(curl 'https://www.tehranmet.ir/fa/widget' \
  -X 'POST' \
  -H 'accept: application/json, text/javascript, */*; q=0.01' \
  -H 'accept-language: en-US,en;q=0.9,fa;q=0.8' \
  -H 'content-length: 0' \
  -H 'cookie: PHPSESSID=ptkicnf1nla4l5ou667t03l7qs' \
  -H 'dnt: 1' \
  -H 'origin: https://www.tehranmet.ir' \
  -H 'priority: u=1, i' \
  -H 'referer: https://www.tehranmet.ir/fa/' \
  -H 'sec-ch-ua: "Chromium";v="124", "Google Chrome";v="124", "Not-A.Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-gpc: 1' \
  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36' \
  -H 'x-requested-with: XMLHttpRequest')
#echo "$api_response"


# Use jq to extract the present temperature for "تهران"
TEMPERATURE=$(echo "$JSON_OUTPUT" | jq -r '.[] | select(.local_station | contains("تهران")) | .present_temperature_c')
MAXRR=$(echo "$JSON_OUTPUT" | jq -r '.[] | select(.local_station | contains("تهران")) | .temp_max_c')
MAXR=$(echo "$MAXRR" | tail -n 1)

MINRR=$(echo "$JSON_OUTPUT" | jq -r '.[] | select(.local_station | contains("تهران")) | .temp_min_c')
MINR=$(echo "$MINRR" | tail -n 1)

MIN=$(echo "scale=1; $MINR" | bc -l)
MAX=$(echo "scale=1; $MAXR" | bc -l)
#printf "<tool>🔴️ $MAX\n🔵️ $MIN</tool>"



if [ -n "$TEMPERATURE" ]; then
	o=$(echo "$TEMPERATURE" | tail -n 1)
	echo "$o" > "$temp_file"
  
else
	#o=""
	o=$(cat "$temp_file")
fi

#printf "<txt>$o°</txt>"
printf "$o°"
