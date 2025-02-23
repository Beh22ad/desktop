local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local beautiful = require("beautiful")
local gears = require("gears")

-- Create the wifi widget
local icon = wibox.widget{
    id = "icon",
    widget = wibox.widget.textbox,
    font = "Font Awesome 6 Free 11",
    text = "󰖪 ",  -- Disconnected WiFi icon
    align = "center",
}

local text = wibox.widget{
    id = "text",
    widget = wibox.widget.textbox,
    text = "No WiFi",
}

local wifi_widget = wibox.widget {
    {
        icon,
        text,
        layout = wibox.layout.fixed.horizontal,
        spacing = 4,
    },
    widget = wibox.container.background,
    bg = beautiful.bg_normal,
    fg = beautiful.fg_normal,
}

-- Function to update widget based on WiFi status
local function update_widget()
    -- Get WiFi connection status using nmcli
    awful.spawn.easy_async_with_shell(
        "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2",
        function(stdout)
            local ssid = stdout:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace

            if ssid ~= "" then
                -- Connected to WiFi
                icon.text = "󰖩 "  -- Connected WiFi icon
                text.text = ssid
            else
                -- Not connected
                icon.text = "󰖪 "  -- Disconnected WiFi icon
                text.text = "No WiFi"
            end
        end
    )
end

-- Function to get current SSID
local function get_current_ssid()
    local cmd = "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2"
    local handle = io.popen(cmd)
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    end
    return ""
end

-- Function to disconnect from current network
local function disconnect_wifi()
    local current_ssid = get_current_ssid()
    if current_ssid ~= "" then
        awful.spawn.easy_async_with_shell(
            string.format("nmcli connection down id '%s'", current_ssid),
            function()
                -- Update widget immediately after disconnecting
                update_widget()
                -- Show notification
                awful.spawn.with_shell(
                    string.format("notify-send 'WiFi' 'Disconnected from %s'", current_ssid)
                )
            end
        )
    end
end

-- Update the widget every 2 seconds
gears.timer {
    timeout = 2,
    call_now = true,
    autostart = true,
    callback = function()
        update_widget()
    end
}

-- Add click functionality
wifi_widget:buttons(
    awful.util.table.join(
        awful.button({}, 1, function()
            -- Left click: open WiFi menu
            awful.spawn.with_shell("~/.config/awesome/script/rofi-wifi-menu.sh")
        end),
        awful.button({}, 3, function()
            -- Right click: disconnect from current network
            disconnect_wifi()
        end)
    )
)

return wifi_widget
