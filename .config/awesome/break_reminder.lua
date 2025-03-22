-------------------------------------------------
-- Break Reminder Widget for AwesomeWM
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty") -- For notifications
local beautiful = require("beautiful") -- For theming

-- Create the widget module
local break_reminder = {}

-- Widget configuration with defaults
break_reminder.config = {
    break_time = 1200, -- 20 minutes in seconds
    thank_time = 20, -- 20 seconds
    break_message = "Take a break",
    thank_message = "Thanks for taking a break",
    sound_file = "/usr/share/sounds/freedesktop/stereo/complete.oga",
    sound_start = "/usr/share/sounds/freedesktop/stereo/message-new-instant.oga",
    icon_color_active = "#33CC33", -- Green when active
    icon_color_inactive = "#CC3333", -- Red when inactive
    icon_color_paused = "#FFCC00", -- Yellow when paused due to fullscreen
    icon_text = "⏲", -- Timer emoji
}

-- Set up the icon widget
break_reminder.icon = wibox.widget {
    {
        id = "icon_text",
        text = break_reminder.config.icon_text,
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    },
    bg = break_reminder.config.icon_color_active, -- Default to active color now
    fg = "#FFFFFF",
    shape = gears.shape.circle,
    widget = wibox.container.background
}

-- Create the widget container
break_reminder.widget = wibox.widget {
    break_reminder.icon,
    layout = wibox.layout.fixed.horizontal
}

-- Variables to track state
break_reminder.active = true -- Changed to true by default
break_reminder.paused = false -- Track if paused due to fullscreen
break_reminder.main_timer = nil
break_reminder.secondary_timer = nil
break_reminder.timer_started_at = 0
break_reminder.time_paused_at = 0 -- Track when paused
break_reminder.elapsed_before_pause = 0 -- Track elapsed before pause
break_reminder.current_phase = "break" -- or "thank"

-- Create a tooltip for the widget
break_reminder.tooltip = awful.tooltip {
    objects = { break_reminder.widget },
    text = "Break reminder active", -- Changed default text
    mode = "outside",
    preferred_positions = { "top", "right", "left", "bottom" },
    margin_leftright = 10,
    margin_topbottom = 5,
}

-- Function to format time in MM:SS format
function break_reminder.format_time(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

-- Function to update the tooltip text
function break_reminder.update_tooltip()
    if not break_reminder.active then
        break_reminder.tooltip.text = "Break reminder (inactive)"
        return
    end

    if break_reminder.paused then
        break_reminder.tooltip.text = "Break reminder (paused - fullscreen detected)"
        return
    end

    local current_time = os.time()
    local elapsed = current_time - break_reminder.timer_started_at + break_reminder.elapsed_before_pause
    local total_time = break_reminder.current_phase == "break"
                       and break_reminder.config.break_time
                       or break_reminder.config.thank_time
    local remaining = math.max(0, total_time - elapsed)

    if break_reminder.current_phase == "break" then
        break_reminder.tooltip.text = "Next break in " .. break_reminder.format_time(remaining)
    else
        break_reminder.tooltip.text = "Thank you notification in " .. break_reminder.format_time(remaining)
    end
end

-- Function to show the first notification
function break_reminder.show_break_notification()
    break_reminder.notification1 = naughty.notify({
        title = "Break Time",
        text = break_reminder.config.break_message,
        timeout = 0, -- 0 means no timeout (stays until dismissed)
        position = "top_right",
        bg = "#3366CC",
        fg = "#FFFFFF",
    })

    -- Update current phase and timer start time
    break_reminder.current_phase = "thank"
    break_reminder.timer_started_at = os.time()
    break_reminder.elapsed_before_pause = 0

    awful.spawn.with_shell("paplay " .. break_reminder.config.sound_start)

    -- Start the second timer
    break_reminder.secondary_timer = gears.timer({
        timeout = break_reminder.config.thank_time,
        autostart = true,
        single_shot = true,
        callback = function()
            break_reminder.show_thanks_notification()
        end
    })
end

-- Function to show the second notification with sound
function break_reminder.show_thanks_notification()
    break_reminder.notification2 = naughty.notify({
        title = "Thank You",
        text = break_reminder.config.thank_message,
        timeout = 5,
        position = "top_right",
        bg = "#33CC33",
        fg = "#FFFFFF",
    })

    -- Play sound with aplay - simplified implementation
    awful.spawn.with_shell("paplay " .. break_reminder.config.sound_file)

    -- If the first notification is still visible, close it
    if break_reminder.notification1 then
        naughty.destroy(break_reminder.notification1)
        break_reminder.notification1 = nil
    end

    -- Reset the main timer to continue the cycle
    if break_reminder.active then
        break_reminder.start_timers()
    end
end

-- Function to start the timers
function break_reminder.start_timers()
    -- Cancel any existing timers
    if break_reminder.main_timer then
        break_reminder.main_timer:stop()
    end
    if break_reminder.secondary_timer then
        break_reminder.secondary_timer:stop()
    end

    -- Reset timer state
    break_reminder.current_phase = "break"
    break_reminder.timer_started_at = os.time()
    break_reminder.elapsed_before_pause = 0

    -- Start the main timer
    break_reminder.main_timer = gears.timer({
        timeout = break_reminder.config.break_time,
        autostart = true,
        single_shot = true,
        callback = function()
            break_reminder.show_break_notification()
        end
    })

    -- Start tooltip update timer (every minute instead of every second)
    if not break_reminder.tooltip_timer then
        break_reminder.tooltip_timer = gears.timer({
            timeout = 60, -- Changed from 1 to 60 for minute-based updates
            autostart = true,
            callback = function()
                break_reminder.update_tooltip()
            end
        })
    else
        break_reminder.tooltip_timer:again()
    end

    -- Update tooltip immediately so it shows correct initial time
    break_reminder.update_tooltip()
end

-- Function to stop the timers
function break_reminder.stop_timers()
    if break_reminder.main_timer then
        break_reminder.main_timer:stop()
        break_reminder.main_timer = nil
    end
    if break_reminder.secondary_timer then
        break_reminder.secondary_timer:stop()
        break_reminder.secondary_timer = nil
    end
    if break_reminder.tooltip_timer then
        break_reminder.tooltip_timer:stop()
    end

    -- Close any existing notifications
    if break_reminder.notification1 then
        naughty.destroy(break_reminder.notification1)
        break_reminder.notification1 = nil
    end
    if break_reminder.notification2 then
        naughty.destroy(break_reminder.notification2)
        break_reminder.notification2 = nil
    end

    -- Update tooltip
    break_reminder.update_tooltip()
end

-- Function to pause the timers
function break_reminder.pause_timers()
    if not break_reminder.paused and break_reminder.active and break_reminder.main_timer then
        -- Store current elapsed time before pausing
        break_reminder.time_paused_at = os.time()
        break_reminder.elapsed_before_pause = break_reminder.elapsed_before_pause +
                                             (break_reminder.time_paused_at - break_reminder.timer_started_at)

        -- Stop the main timer
        break_reminder.main_timer:stop()

        -- Set paused state
        break_reminder.paused = true
        break_reminder.icon.bg = break_reminder.config.icon_color_paused

        -- Update the tooltip
        break_reminder.update_tooltip()
    end
end

-- Function to resume the timers
function break_reminder.resume_timers()
    if break_reminder.paused and break_reminder.active then
        -- Update the timer start time
        break_reminder.timer_started_at = os.time()

        -- Calculate remaining time
        local total_time = break_reminder.current_phase == "break"
                          and break_reminder.config.break_time
                          or break_reminder.config.thank_time
        local remaining = math.max(0, total_time - break_reminder.elapsed_before_pause)

        -- Restart the timer with the remaining time
        break_reminder.main_timer = gears.timer({
            timeout = remaining,
            autostart = true,
            single_shot = true,
            callback = function()
                if break_reminder.current_phase == "break" then
                    break_reminder.show_break_notification()
                else
                    break_reminder.show_thanks_notification()
                end
            end
        })

        -- Set active state
        break_reminder.paused = false
        break_reminder.icon.bg = break_reminder.config.icon_color_active

        -- Update the tooltip
        break_reminder.update_tooltip()
    end
end

-- Function to toggle the reminder on/off
function break_reminder.toggle()
    break_reminder.active = not break_reminder.active

    if break_reminder.active then
        break_reminder.icon.bg = break_reminder.paused
                               and break_reminder.config.icon_color_paused
                               or break_reminder.config.icon_color_active
        break_reminder.start_timers()
        naughty.notify({
            title = "Break Reminder",
            text = "Break reminder activated",
            timeout = 2,
        })
    else
        break_reminder.icon.bg = break_reminder.config.icon_color_inactive
        break_reminder.stop_timers()
        naughty.notify({
            title = "Break Reminder",
            text = "Break reminder deactivated",
            timeout = 2,
        })
    end
end

-- Function to toggle pause state
function break_reminder.toggle_pause()
    if not break_reminder.active then
        -- If inactive, don't do anything
        return
    end

    if break_reminder.paused then
        break_reminder.resume_timers()
        naughty.notify({
            title = "Break Reminder",
            text = "Timer resumed",
            timeout = 2,
        })
    else
        break_reminder.pause_timers()
        naughty.notify({
            title = "Break Reminder",
            text = "Timer paused",
            timeout = 2,
        })
    end
end

-- Set up mouse buttons for the widget
break_reminder.widget:buttons(gears.table.join(
    awful.button({ }, 1, function() -- Left click
        break_reminder.toggle()
    end),
    awful.button({ }, 3, function() -- Right click
        break_reminder.toggle_pause()
    end)
))

-- Initialize widget (optional)
function break_reminder.init(user_config)
    -- Override default config with user config
    if user_config then
        for key, value in pairs(user_config) do
            break_reminder.config[key] = value
        end
    end

    -- Apply initial styling for active state
    break_reminder.icon.bg = break_reminder.config.icon_color_active

    -- Initialize the tooltip
    break_reminder.update_tooltip()

    -- Function to check if any client is in fullscreen mode
    function break_reminder.check_fullscreen()
        local any_fullscreen = false
        for _, cl in ipairs(client.get()) do
            if cl.fullscreen then
                any_fullscreen = true
                break
            end
        end

        -- Pause or resume based on fullscreen state
        if any_fullscreen then
            break_reminder.pause_timers()
        else
            break_reminder.resume_timers()
        end
    end

    -- Set up fullscreen client detection
    client.connect_signal("property::fullscreen", function(c)
        break_reminder.check_fullscreen()
    end)

    -- Also check when clients are added or removed
    client.connect_signal("manage", function(c)
        break_reminder.check_fullscreen()
    end)

    client.connect_signal("unmanage", function(c)
        -- Use a small delay to ensure the client list is updated
        gears.timer.start_new(0.1, function()
            break_reminder.check_fullscreen()
            return false -- Don't restart the timer
        end)
    end)

    -- Start timers since we're active by default
    break_reminder.start_timers()

    return break_reminder.widget
end

-- Return the widget
return break_reminder
