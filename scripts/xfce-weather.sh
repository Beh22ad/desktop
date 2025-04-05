#!/bin/bash

LOG_FILE="/tmp/weather_roojino.log"
ICON_PATH="$HOME/D/setup/linux/user/scripts/weather/"

CITY=${1:-tehran}

declare -A ICON_MAP=(
    ["01d"]="clear-sky"
    ["02d"]="few-clouds"
    ["03d"]="scattered-clouds"
    ["04d"]="broken-clouds"
    ["09d"]="shower-rain"
    ["10d"]="rain"
    ["11d"]="thunderstorm"
    ["13d"]="snow"
    ["50d"]="mist"
    ["01n"]="clear-sky-night"
    ["02n"]="few-clouds-night"
    ["03n"]="scattered-clouds-night"
    ["04n"]="broken-clouds-night"
    ["09n"]="shower-rain-night"
    ["10n"]="rain-night"
    ["11n"]="thunderstorm-night"
    ["13n"]="snow-night"
    ["50n"]="mist-night"
)

get_weather_data() {
    curl -s "https://roojino.ir/w.php?city=$CITY"
}

update_widget() {
    local weather_data=$(get_weather_data)

    if [[ -n "$weather_data" ]]; then
        local temp=$(echo "$weather_data" | jq -r '.temp')
        local icon_code=$(echo "$weather_data" | jq -r '.icon')

        local icon_name=${ICON_MAP[$icon_code]:-"unknown"}
        local icon_file="$ICON_PATH$icon_name.svg"

        echo "$weather_data" > "$LOG_FILE"

        echo "<txt><span weight='normal' fgcolor='White' gravity='east'  >$temp°C</span></txt>"
        echo "<img>$icon_file</img>"
    else
        if [[ -f "$LOG_FILE" ]]; then
            local weather_data=$(cat "$LOG_FILE")
            local temp=$(echo "$weather_data" | jq -r '.temp')
            local icon_code=$(echo "$weather_data" | jq -r '.icon')

            local icon_name=${ICON_MAP[$icon_code]:-"unknown"}
            local icon_file="$ICON_PATH$icon_name.svg"

            echo "<txt><span weight='normal' fgcolor='White' gravity='east'  >$temp°C</span></txt>"
            echo "<img>$icon_file</img>"
        else
            echo "<txt>?</txt>"
        fi
    fi
}


update_widget

