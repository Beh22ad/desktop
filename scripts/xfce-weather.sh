#!/bin/bash

# 定义日志文件路径
LOG_FILE="/tmp/weather_roojino.log"
# 定义图标路径
ICON_PATH="$HOME/D/setup/linux/user/scripts/weather/"

# 定义城市（默认为 Tehran）
CITY=${1:-tehran}

# 定义图标映射
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

# 获取天气数据
get_weather_data() {
    curl -s "https://roojino.ir/w.php?city=$CITY"
}

# 更新天气小部件
update_widget() {
    # 尝试从 API 获取数据
    local weather_data=$(get_weather_data)

    if [[ -n "$weather_data" ]]; then
        # 解析 JSON 数据
        local temp=$(echo "$weather_data" | jq -r '.temp')
        local icon_code=$(echo "$weather_data" | jq -r '.icon')

        # 获取图标名称
        local icon_name=${ICON_MAP[$icon_code]:-"unknown"}
        local icon_file="$ICON_PATH$icon_name.svg"

        # 更新日志文件
        echo "$weather_data" > "$LOG_FILE"

        # 输出 Xfce4 Generic Monitor 插件的格式
        echo "<txt>$temp°C</txt>"
        echo "<img>$icon_file</img>"
    else
        # 如果 API 请求失败，从日志文件中读取数据
        if [[ -f "$LOG_FILE" ]]; then
            local weather_data=$(cat "$LOG_FILE")
            local temp=$(echo "$weather_data" | jq -r '.temp')
            local icon_code=$(echo "$weather_data" | jq -r '.icon')

            # 获取图标名称
            local icon_name=${ICON_MAP[$icon_code]:-"unknown"}
            local icon_file="$ICON_PATH$icon_name.svg"

            # 输出 Xfce4 Generic Monitor 插件的格式
            echo "<txt>$temp°C</txt>"
            echo "<img>$icon_file</img>"
        else
            # 如果日志文件不存在，显示错误信息
            echo "<txt>Error: No data available</txt>"
        fi
    fi
}


update_widget

