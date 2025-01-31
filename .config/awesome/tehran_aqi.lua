local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- Debug mode
local DEBUG = false

-- Debug notification function
local function debug_notify(title, text)
    if DEBUG then
        naughty.notify({
            title = "Debug: " .. title,
            text = text,
            timeout = 10,
            bg = "#000066"
        })
    end
end

-- Tehran AQI Widget
local tehran_aqi = {}
local CACHE_FILE = "/tmp/tehran_aqi_cache"
local RAW_FILE = "/tmp/tehran_aqi_raw"

-- Create the text widget
local aqi_widget = wibox.widget {
    {
        {
            id = "txt",
            font = "sans 11",
            widget = wibox.widget.textbox
        },
        margins = 4,
        widget = wibox.container.margin
    },
    bg = beautiful.bg_normal,
    fg = beautiful.notification_fg,
    widget = wibox.container.background
}

-- Function to update widget colors based on AQI value
local function update_widget_style(value)
    local bg, fg
    if value < 80 then
        bg = "#4CAF50"  -- Green
        fg = "#ffffff"
    elseif value < 100 then
        bg = beautiful.bg_normal
        fg = beautiful.notification_fg
    elseif value < 120 then
        bg = "#FF9800"  -- Orange
        fg = "#ffffff"
    else
        bg = "#dd4b39"  -- Red
        fg = "#ffffff"
    end

    aqi_widget.bg = bg
    aqi_widget.fg = fg
end

-- Function to save AQI value to cache file
local function save_to_cache(value)
    awful.spawn.with_shell(string.format("echo '%d,%d' > %s", value, os.time(), CACHE_FILE))
    debug_notify("Cache Save", string.format("Saved value %d to cache", value))
end

-- Function to read AQI value from cache file
local function read_from_cache(callback)
    awful.spawn.easy_async(string.format("cat %s 2>/dev/null", CACHE_FILE),
        function(stdout, stderr, reason, exit_code)
            if exit_code == 0 and stdout ~= "" then
                local value, timestamp = stdout:match("(%d+),(%d+)")
                if value and timestamp then
                    debug_notify("Cache Read", string.format("Read value %s from cache, timestamp %s", value, timestamp))
                    callback(tonumber(value), tonumber(timestamp))
                else
                    debug_notify("Cache Read Error", "Failed to parse cache content: " .. stdout)
                    callback(nil, nil)
                end
            else
                debug_notify("Cache Read Error", "Failed to read cache file")
                callback(nil, nil)
            end
        end
    )
end

-- Function to extract AQI value from HTML content
local function extract_aqi_value(html_content, callback)
    -- Write content to temporary file
    awful.spawn.with_shell(string.format("echo '%s' > %s", html_content:gsub("'", "'\\''"), RAW_FILE))

    -- Use awk to extract the value (more reliable than grep)
    awful.spawn.easy_async_with_shell(
        string.format([[awk 'match($0, /ContentPlaceHolder1_lblAqi3h.*aqival">([0-9]+)/, arr) {print arr[1]}' %s]], RAW_FILE),
        function(stdout, stderr, reason, exit_code)
            debug_notify("Value Extraction",
                string.format("Exit code: %d\nAQI: %s",
                    exit_code, stdout or "nil"))

            if exit_code == 0 and stdout ~= "" then
                local value = tonumber(stdout)
                if value then
                    debug_notify("Value Found", string.format("Extracted AQI value: %d", value))
                    callback(value)
                    return
                end
            end

            debug_notify("Extraction Failed", "Falling back to cache")
            read_from_cache(function(cached_value, cached_time)
                if cached_value and os.time() - cached_time < 7200 then
                    callback(cached_value)
                else
                    callback(nil)
                end
            end)
        end
    )
end

-- Function to update widget with value
local function set_aqi_value(value)
    if value then
        debug_notify("Widget Update", string.format("Setting AQI value to: %d", value))
        aqi_widget:get_children_by_id("txt")[1]:set_text(" AQI: " .. value .. " ")
        update_widget_style(value)
        save_to_cache(value)
    else
        debug_notify("Widget Update", "Setting AQI to N/A")
        aqi_widget:get_children_by_id("txt")[1]:set_text(" AQI ")
        aqi_widget.bg = beautiful.bg_normal
        aqi_widget.fg = "#ffffff"
    end
end

-- Function to fetch AQI data
local function fetch_aqi_data(callback)
    debug_notify("Fetch Start", "Starting AQI data fetch")

    -- Use curl with extended options for better reliability
    awful.spawn.easy_async(
        [[curl -s -H "User-Agent: Mozilla/5.0" -H "Accept: text/html" 'https://airnow.tehran.ir/']],
        function(stdout, stderr, reason, exit_code)
            debug_notify("Curl Result", string.format("Exit code: %d", exit_code))

            if exit_code == 0 and stdout ~= "" then
                extract_aqi_value(stdout, callback)
            else
                debug_notify("Curl Failed", "Falling back to cache")
                read_from_cache(function(cached_value, cached_time)
                    if cached_value and os.time() - cached_time < 7200 then
                        callback(cached_value)
                    else
                        callback(nil)
                    end
                end)
            end
        end
    )
end

-- Update function for the widget
local function update_widget()
    fetch_aqi_data(set_aqi_value)
end

-- Set up timer for updates (every 30 minutes)
local update_timer = gears.timer {
    timeout = 1800,
    call_now = true,
    autostart = true,
    callback = update_widget
}

-- Add click-to-update functionality
aqi_widget:buttons(
    awful.util.table.join(
        awful.button({}, 1, function()  -- Left click
            naughty.notify({
                title = "Tehran AQI",
                text = "Updating...",
                timeout = 2
            })
            update_widget()
        end),
        awful.button({}, 3, function()  -- Right click
            -- Show current cache content
            awful.spawn.easy_async(string.format("cat %s 2>/dev/null", CACHE_FILE),
                function(stdout)
                    naughty.notify({
                        title = "Debug: Cache Content",
                        text = stdout ~= "" and stdout or "Cache is empty",
                        timeout = 10
                    })
                end
            )
        end)
    )
)

-- Initial update
update_widget()

return aqi_widget
