local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local json = require("json")
local HOME = os.getenv('HOME')
local log_file = "/tmp/weather_roojino.log"
local naughty = require("naughty")

local function create_weather_widget(user_args)
    local weather_widget = wibox.widget {
        {
            id = "icon",
            widget = wibox.widget.imagebox,
        },
        {
            id = "temp",
            widget = wibox.widget.textbox,
            font = "Sans 11",

        },
        layout = wibox.layout.fixed.horizontal,
    }

    local icon_map = {
        ["01d"] = "clear-sky",
        ["02d"] = "few-clouds",
        ["03d"] = "scattered-clouds",
        ["04d"] = "broken-clouds",
        ["09d"] = "shower-rain",
        ["10d"] = "rain",
        ["11d"] = "thunderstorm",
        ["13d"] = "snow",
        ["50d"] = "mist",
        ["01n"] = "clear-sky-night",
        ["02n"] = "few-clouds-night",
        ["03n"] = "scattered-clouds-night",
        ["04n"] = "broken-clouds-night",
        ["09n"] = "shower-rain-night",
        ["10n"] = "rain-night",
        ["11n"] = "thunderstorm-night",
        ["13n"] = "snow-night",
        ["50n"] = "mist-night"
    }

    local function update_widget(widget, city)


        local command = "curl -s 'https://roojino.ir/w.php?city=" .. city .. "'"
        awful.spawn.easy_async_with_shell(command, function(stdout)
            if stdout and stdout ~= "" then
                local weather_data = json.decode(stdout)
                local temp = weather_data.temp
                local icon_code = weather_data.icon
                local icon_name = icon_map[icon_code] or "unknown"
                local icon_path = HOME .. "/.config/awesome/icons/weather/" .. icon_name .. ".svg"
                widget:get_children_by_id("temp")[1]:set_markup_silently("<span foreground='#FFDAF7'>" .. temp .. "°C</span>")
                widget:get_children_by_id("icon")[1]:set_image(icon_path)
				if temp ~= "" then
					-- Save to log file
					local file = io.open(log_file, "w")
					if file then
						file:write(stdout)
						file:close()
					end
				end
            else
                -- Read from log file if API call fails
                local file = io.open(log_file, "r")
                if file then
                    local log_data = file:read("*all")
                    file:close()
                    if log_data and log_data ~= "" then
                        local weather_data = json.decode(log_data)
                        local temp = weather_data.temp
                        local icon_code = weather_data.icon
                        local icon_name = icon_map[icon_code] or "unknown"
                        local icon_path = HOME .. "/.config/awesome/icons/weather/" .. icon_name .. ".png"
                        widget:get_children_by_id("temp")[1]:set_text(temp .. "°C")
                        widget:get_children_by_id("icon")[1]:set_image(icon_path)
                    end
                end
            end
        end)
    end

    -- Update the widget immediately with the desired city
    local city = user_args.city or "tehran"
    update_widget(weather_widget, city)

    -- Set up the timer to update the widget every 10 minutes
    gears.timer {
        timeout = 600,  -- Update every 10 minutes
        autostart = true,
        callback = function() update_widget(weather_widget, city) end
    }

    -- Add mouse click event to update the widget and show notification
    weather_widget:buttons(
        gears.table.join(
            awful.button({}, 1, function() update_widget(weather_widget, city)
            -- Show notification that the widget is updating
			naughty.notify({ text = "Updating weather...",timeout = 1, })
            end)
        )
    )

    return weather_widget
end

return create_weather_widget
