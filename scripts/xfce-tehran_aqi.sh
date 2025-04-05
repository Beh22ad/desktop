#!/bin/bash
# tehran_aqi.sh
# A script to fetch Tehran AQI, cache it, and output a formatted value for Xfce's Generic Monitor.
# Clicking the panel (or setting it to update periodically) will re-run this script.

CACHE_FILE="/tmp/tehran_aqi_cache"
RAW_FILE="/tmp/tehran_aqi_raw"
URL="https://airnow.tehran.ir/"
CACHE_MAX_AGE=7200  # 2 hours in seconds

# Function to get current epoch time.
current_time() {
    date +%s
}

# Function to fetch AQI from the website.
fetch_aqi() {
    # Fetch the raw HTML.
    raw=$(curl -s -H "User-Agent: Mozilla/5.0" -H "Accept: text/html" "$URL")
    # Save raw content for debugging if needed.
    echo "$raw" > "$RAW_FILE"
    # Use awk to extract the AQI value from the HTML.
    aqi=$(echo "$raw" | awk 'match($0, /ContentPlaceHolder1_lblAqi3h.*aqival">([0-9]+)/, a) {print a[1]}')
    echo "$aqi"
}

# Function to read the AQI from cache if it exists and is not too old.
read_cache() {
    if [[ -f "$CACHE_FILE" ]]; then
        IFS=',' read -r cached_aqi cached_time < "$CACHE_FILE"
        current=$(current_time)
        age=$(( current - cached_time ))
        if (( age < CACHE_MAX_AGE )); then
            echo "$cached_aqi"
            return 0
        fi
    fi
    return 1
}

# Function to save the AQI value with current timestamp.
save_cache() {
    local value="$1"
    echo "$value,$(current_time)" > "$CACHE_FILE"
}

# Main logic: try fetching, then fall back to cache if necessary.
aqi_value=$(fetch_aqi)

# Determine emoji based on AQI value
if [[ -z "$aqi_value" ]]; then
    # If fetch failed or no value extracted, try to use cache.
    aqi_value=$(read_cache)
fi

# Output the AQI value with an emoji based on the value
if [[ -n "$aqi_value" ]]; then
    save_cache "$aqi_value"

    if (( aqi_value < 80 )); then
    echo "<txt><span weight='normal' fgcolor='White' bgcolor='#4CAF50' gravity='east'  > $aqi_value </span></txt>"

    elif (( aqi_value < 100 )); then
        echo "<txt><span weight='normal' fgcolor='White' gravity='east'  > $aqi_value </span></txt>"
    elif (( aqi_value < 120 )); then
         echo "<txt><span weight='normal' fgcolor='White' bgcolor='#FF9800' gravity='east'  > $aqi_value </span></txt>"
    else
        echo "<txt><span weight='normal' fgcolor='White' bgcolor='#dd4b39' gravity='east'  > $aqi_value </span></txt>"
    fi
else
    echo "N/A"
fi
