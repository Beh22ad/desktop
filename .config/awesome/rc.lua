-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")
local home = os.getenv("HOME")
--local downloadMeter = home .. '/.config/awesome/script/download-meter-raw.sh'
--local Fadate = home .. "/.config/awesome/script/full-data.sh"

local batteryarc_widget = require("batteryarc")
local logout_menu_widget = require("logout-menu")
local weather_widget = require("weather")
-- Import the WiFi widget
local wifi_widget = require("wifi_widget")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

local function rounded_shape(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

naughty.config.presets.normal = {
    position = "bottom_right", -- 'top_right',
    ontop = true,
    margin = 10,
   border_width = 2,
    timeout = 3,
  --  width = 200,
    font = "Sans Bold 13",
    shape = rounded_shape(10),
}
-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/theme.lua")

--! Run autostart.sh
awful.spawn.with_shell("~/.config/awesome/autorun.sh")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator -e fish" -- "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.spiral,
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}


-- AQI Widget شاخص آلودگی هوای تهران
local tehran_aqi = require("tehran_aqi")
local AQI = wibox.container.margin(tehran_aqi, 0, 3, 5, 5)




-- spacer
local _ = wibox.container.margin()
_:set_right(5)
_:set_left(5)


-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()
local keyboard_box = wibox.container.margin(mykeyboardlayout.widget)
keyboard_box:set_top(5)
keyboard_box:set_left(10)
keyboard_box:set_right(5)
local function update_keyboard_layout()
    local layout = mykeyboardlayout.widget.text
    local color = beautiful.bg_normal
    if layout == " ir " or layout == "🇮🇷" then
        color = beautiful.bg_minimize  -- Green for "ir"
        mykeyboardlayout.widget:set_markup('<span font="sans bold 12" color="' .. color .. '">🇮🇷</span>')
	else
		 mykeyboardlayout.widget:set_markup('<span font="sans bold 12" color="' .. color .. '">🇺🇸</span>')
	end

end

-- Connect the function to the signal that is triggered when the layout changes
mykeyboardlayout:connect_signal("widget::redraw_needed", function()
    update_keyboard_layout()
end)

keyboard_box:connect_signal("button::press", function()
    mykeyboardlayout:next_layout ()
end)

-- Initial update
update_keyboard_layout()


-- Function to disable Caps Lock
local function disable_capslock()
    awful.spawn.with_shell("xdotool key Caps_Lock")
end

-- Create a timer to check and disable Caps Lock every second
local capslock_timer = gears.timer {
    timeout = 1,  -- 1 second interval
    call_now = true,
    autostart = true,
    callback = function()
        -- Check if Caps Lock is on
        awful.spawn.easy_async_with_shell(
            "xset q | grep -q 'Caps Lock:   on'",
            function(stdout, stderr, reason, exit_code)
                if exit_code == 0 then
                    -- If Caps Lock is on, disable it
                    disable_capslock()
                end
            end
        )
    end
}


-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end)
                 --  awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                 --  awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end




-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
 awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

-- Create the SVG icon widget for start menu
local svg_icon_widget0 = wibox.widget {
    {
        image = home .. "/.config/awesome/icons/wibar/start.svg",
        resize = true,
        forced_width = 20,
        forced_height = 20,
        widget = wibox.widget.imagebox,
    },
    widget = wibox.container.margin, -- Add margins if needed
}
local svg_icon_widget = wibox.container.margin(svg_icon_widget0, 5, 5, 5, 5)
-- Set up the click event to run jgmenu_run
svg_icon_widget:buttons(awful.util.table.join(
    awful.button({}, 1, function()
        awful.spawn.with_shell("rofi -show drun")
    end),
    awful.button({}, 3, function()
        awful.spawn.with_shell("~/.config/awesome/script/power-menu.sh")
    end)
))


-- Farsi date
local data_textbox = wibox.widget.textbox()
data_textbox:set_markup('<span font="Vazirmatn 10" foreground="'..beautiful.notification_fg..'">...</span>')

local function update_data()
    awful.spawn.easy_async([[bash -c '/home/b/.config/awesome/script/full-data.sh']], function(stdout)
        -- Trim any trailing newlines or spaces
        local trimmed_output = stdout:gsub("^%s*(.-)%s*$", "%1")
        -- Update the data_textbox with the correct font and color
        data_textbox:set_markup(string.format('<span font="Vazirmatn 10" foreground="'..beautiful.notification_fg..'">%s</span>', trimmed_output))
    end)
end

update_data()

gears.timer {
    timeout   = 60,
    call_now  = true,
    autostart = true,
    callback  = update_data
}



-- download data meter
    local download_textbox = wibox.widget.textbox()
    download_textbox:set_markup('<span font="Vazirmatn 11" foreground="'..beautiful.notification_fg..'">...</span>')
    local download_widget = wibox.container.margin(download_textbox, 5, 5, 5, 5)
    local function update_download()
    awful.spawn.easy_async([[bash -c '/home/b/.config/awesome/script/download-meter-raw.sh']], function(stdout)
        local trimmed_output = stdout:gsub("^%s*(.-)%s*$", "%1")
        -- Update the data_textbox with the correct font and color
        download_textbox:set_markup(string.format('<span font="Vazirmatn 10" foreground="'..beautiful.notification_fg..'">%s</span>', trimmed_output))
		end)
	end
	update_download()
	gears.timer {
		timeout   = 5,
		call_now  = true,
		autostart = true,
		callback  = update_download
	}

-- Create the time widget with the desired font size, bold, and white color

-- Create the widgets
time_widget = wibox.widget.textbox()
date_widget = wibox.widget.textbox()
date_widget.visible = false

-- Set initial styling
--time_widget.font = 10
time_widget.markup = '<span color="'..beautiful.notification_fg..'" font="10">Time</span>'

--date_widget.font =10
date_widget.markup = '<span color="'..beautiful.notification_fg..'" font="Bold 12">Date</span>'

-- Create a function to update time
local function update_time()
    local time_text = os.date("%I:%M %p")
    time_widget.markup = '<span color="'..beautiful.notification_fg..'" font="10">' .. time_text .. '</span>'
end

-- Create a function to update date
local function update_date()
    local date_text = os.date(" %B \n %Y/%m/%d ")
    date_widget.markup = '<span color="'..beautiful.notification_fg..'" font="Bold 12">' .. date_text .. '</span>'
end

-- Timer to update time every minute
gears.timer {
    timeout = 60,
    autostart = true,
    callback = function()
        update_time()
        update_date()
    end
}
-- Add padding around the time and date widgets using wibox.container.margin
local padded_time_widget = wibox.container.margin(time_widget, 5, 0, 0, 0)
local padded_date_widget = wibox.container.margin(date_widget, 5, 5, 5, 5)

-- Create a container for both padded widgets
local time_date_widget = wibox.widget {
    padded_time_widget,
    padded_date_widget,
    layout = wibox.layout.fixed.horizontal,
}



-- Initial update
update_date()
update_time()





-- Display date as a notification when clicking on the time widget
time_widget:connect_signal("button::press", function()
    local date_text = os.date("%B \n %Y/%m/%d")
    naughty.notify {
        text = date_text,
        timeout = 5,
        preset = naughty.config.presets.normal,

    }
end)




    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    s.mylayoutbox.resize = true
	s.mylayoutbox.forced_height = 18
	s.mylayoutbox.forced_width = 18

	-- Wrap the layoutbox in a place container to center it
	local centered_layoutbox = wibox.container.place(s.mylayoutbox, "center")

    -- Create a taglist widget
s.mytaglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    layout = {
        spacing = 0,
        layout = wibox.layout.fixed.horizontal,
    },
    buttons = taglist_buttons,
    widget_template = {
        {
            {
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
                widget = wibox.container.place,  -- This centers the text
            },
            forced_width = 30,  -- Set the desired width here
            widget = wibox.container.background,
        },
        id     = 'background_role',
        widget = wibox.container.background,
    }
}



-- Tasklist buttons
local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", {raise = true})
        end
    end),
    awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
    awful.button({ }, 4, function() awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function() awful.client.focus.byidx(-1) end)
)



-- Custom tasklist widget template
local function create_tasklist_widget(s)
    -- Define the buttons, including middle-click to close
    local tasklist_buttons = gears.table.join(
        awful.button({ }, 1, function (c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal(
                    "request::activate",
                    "tasklist",
                    {raise = true}
                )
            end
        end),
        awful.button({ }, 2, function(c)
            c:kill()
        end),
        awful.button({ }, 3, function(c)
            -- Create a custom menu for right-click
            if not c._right_click_menu then
                c._right_click_menu = awful.menu({
                    items = {
                        { "Toggle Floating", function() c.floating = not c.floating end },
                        { "Toggle On Top", function() c.ontop = not c.ontop end },
                        { "Close", function() c:kill() end }
                    }
                })
            end

            -- Hide the menu if it's already visible
            if c._right_click_menu.visible then
                c._right_click_menu:hide()
            else
                c._right_click_menu:show()
            end
        end),
        awful.button({ }, 4, function ()
            awful.client.focus.byidx(1)
        end),
        awful.button({ }, 5, function ()
            awful.client.focus.byidx(-1)
        end)
    )

    return awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,  -- Use the buttons we defined
        style = {
            shape = gears.shape.rectangle,
        },
        layout = {
            spacing = 4,
            layout = wibox.layout.flex.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'clienticon',
                            widget = awful.widget.clienticon,
                        },
                        margins = 5,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left   = 10,
                right  = 10,
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
            create_callback = function(self, c, index, objects)
                self:get_children_by_id('clienticon')[1].client = c
            end,
        },
    }
end



-- systray
--beautiful.systray_icon_spacing = 5
mysystray = wibox.widget.systray()
mysystray:set_base_size(18)
local mysystray_widget = wibox.container.margin(mysystray, 5, 2, 5, 0)
--local mysystray_widget = wibox.container.margin(mysystray, 5, 0, 3.5, 8)





-- Use this function to create the tasklist for each screen
s.mytasklist = create_tasklist_widget(s)




    -- Create the wibox "bottom"
    s.mywibox = awful.wibar({ position = "top", screen = s , bg = beautiful.bg_normal })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,

        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
          --  mylauncher,
			svg_icon_widget,
            s.mytaglist,

           _,centered_layoutbox, _,
            s.mypromptbox,

        },
        s.mytasklist, -- Middle widget
        { -- Right widgets

		{
            { -- Keyboard layout widget container
				layout = wibox.layout.fixed.vertical,
			--	mykeyboardlayout,
			keyboard_box,
			},
			batteryarc_widget({
						show_notification_mode = "on_click",
					--	notification_position = "bottom_right",
						show_current_level = true,
						arc_thickness = 2,
						size=15,
					}),

            mysystray_widget,
			_,wifi_widget,
            download_widget,
            AQI,
            weather_widget({
						city = "tehran",
					}),_,
            data_textbox,
            _,time_date_widget,
            --mytextclock,

          --  logout_menu_widget{font = 'Play 14', onlock = function() awful.spawn.with_shell'i3lock-fancy') end},
        layout = wibox.layout.fixed.horizontal,
       },

       widget = wibox.container.background,
    bg     = beautiful.bg_normal,
    shape  = gears.shape.rounded_bar
        }
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    --awful.button({ }, 3, function () awful.util.spawn_with_shell("jgmenu_run") end)
    awful.button({ }, 3, function () awful.util.spawn_with_shell("rofi -show drun") end)
--    awful.button({ }, 3, function () mymainmenu:toggle() end),
--    awful.button({ }, 4, awful.tag.viewnext),
--    awful.button({ }, 5, awful.tag.viewprev)
))


-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
  --  awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
  --            {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    --~awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              --~{description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", function () awful.util.spawn_with_shell("bl-exit") end ,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,     "Control" , "Shift"     }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    --start app key

     awful.key({ modkey },            "f",     function () awful.util.spawn("thunar") end,
              {description = "Thunar", group = "launcher"}),
     awful.key({ modkey },            "c",     function () awful.util.spawn("google-chrome") end,
              {description = "Chrome", group = "launcher"}),
     awful.key({ modkey },            "g",     function () awful.util.spawn("geany") end,
              {description = "geany", group = "launcher"}),
     awful.key({ modkey },            ".",     function () awful.util.spawn_with_shell("~/.local/bin/rofimoji --hidden-descriptions --selector-args='-theme ~/.config/rofi/themes/moji.rasi'") end,
              {description = "rofimoji", group = "launcher"}),

	  awful.key({ modkey },            "Up",     function () awful.util.spawn_with_shell("amixer set Master 5%+") end,{description = "Volume+", group = "client"}),
	   awful.key({ modkey },            "Down",     function () awful.util.spawn_with_shell("amixer set Master 5%-") end,{description = "Volume-", group = "client"}),

	   awful.key( {"Control"}, "Scroll_Lock",     function () awful.util.spawn_with_shell("xbacklight -set 50") end,{description = "brightness 50% ", group = "client"}),

	   awful.key( {}, "Scroll_Lock",     function () awful.util.spawn_with_shell("xbacklight -set 30") end,{description = "brightness 30 ", group = "client"}),

	   awful.key({ modkey },            "a",     function () awful.util.spawn_with_shell("xbacklight -set 0") end,{description = "brightness off", group = "client"}),


	   awful.key({ modkey },            "q",     function () awful.util.spawn_with_shell("xbacklight -set 30") end,{description = "brightness 30%", group = "client"}),

	   awful.key({ modkey },            "Scroll_Lock",     function () awful.util.spawn_with_shell("xbacklight -set 0") end,{description = "brightness off", group = "client"}),

	   awful.key({  },            "Print",     function () awful.util.spawn_with_shell("flameshot gui") end,{description = "Screen shot", group = "client"}),

	   --awful.key({ modkey },     " "    ,     function () awful.util.spawn_with_shell("jgmenu_run") end,{description = "Menu", group = "client"}),
	   awful.key({ modkey },     " "    ,     function () awful.util.spawn_with_shell("rofi -show drun") end,{description = "Menu", group = "client"}),
	   awful.key({ modkey },       "h"     ,     function () awful.util.spawn_with_shell("x-terminal-emulator -T 'htop task manager' -e htop") end,{description = "Htop", group = "client"}),
	   awful.key({ modkey },       "Escape"     ,     function () awful.util.spawn_with_shell("systemctl suspend") end,{description = "sleep", group = "client"}),
	   --~awful.key({ modkey },       "v"     ,     function () awful.util.spawn_with_shell("xfce4-clipman-history") end,{description = "Clip board", group = "client"}),

	   awful.key({ modkey, "Control" }, "k", function() awful.spawn.with_shell("setxkbmap -option ctrl:nocaps") end, {description = "Remap Caps Lock to Ctrl", group = "custom"}),





    --End app key

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,   "Control"        }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                              awful.tag.viewonly(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.centered + awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "WmanExit",
          "Mirage",
          "mpv",
          "vlc",
          "Galculator",
          "Lxappearance",
          "mother.py",
          "oblivion-desktop",
          "Uget-gtk",
          "Xfce4-clipman-history",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},
       { rule = { class = "qView" },
        properties = { floating = true, maximized = true },
		},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
     { rule = { class = "Thunar" },
       properties = { screen = 1, tag = "2" } },
     { rule = { class = "Google-chrome" },
       properties = { screen = 1, tag = "1"  } },

     { rule = { class = "Geany" },
       properties = { screen = 1, tag = "3" } },
       { rule = { class = "Pavucontrol" },
       properties = { screen = 1, tag = "9", floating = true, minimized = true } },
       -- move mpv to active tag
       { rule = { class = "mpv" },
      properties = {
      border_width = 0,
      },
      callback = function(c)
        local function move_to_focused_tag(c)
            if c.valid then
                local t = awful.screen.focused().selected_tag
                if t and c.first_tag ~= t then
                    c:move_to_tag(t)
                end
            end
        end

        c:connect_signal("property::screen", move_to_focused_tag)

        local tag_selected_signal = function(t)
            if t.selected then
                move_to_focused_tag(c)
            end
        end

        tag.connect_signal("property::selected", tag_selected_signal)

        c:connect_signal("unmanage", function()
            tag.disconnect_signal("property::selected", tag_selected_signal)
        end)
      end
    },
    ---
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)



-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c ) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
--~client.connect_signal("mouse::enter", function(c)
    --~c:emit_signal("request::activate", "mouse_enter", {raise = false})
--~end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus;  end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal;  end)
-- }}}


-- border for active windows only

beautiful.gap_single_client = false

screen.connect_signal("arrange", function(s)
    local only_one = #s.tiled_clients == 1

    for _, c in pairs(s.clients) do
        -- Check for single window, maximized, or fullwidth conditions
        if (only_one and not c.floating) or c.maximized or (c.fullwidth and not c.floating) then
            c.border_width = 0
            c.shape = gears.shape.rectangle
        else
            c.border_width = beautiful.border_width
            c.shape = function(cr, w, h)
                gears.shape.rounded_rect(cr, w, h, beautiful.border_radius)
            end
        end
    end
end)


-- fix mpv on top
client.connect_signal("property::fullscreen", function(c)
    if c.class == "mpv" then
        if c.fullscreen then
            c.ontop = false
        else
            c.ontop = true
        end
    end
end)

--~-- Function to remove border radius when fullscreen
client.connect_signal("property::fullscreen", function(c)
    if c.fullscreen then
        -- Remove rounded corners when fullscreen
        c.shape = gears.shape.rectangle
        c.border_width = 0
    else
        c.shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, beautiful.border_radius)
				end
    end
end)



-- jump to urgent client
client.connect_signal("property::urgent", function(c)
    if c.urgent then
        local t = c.first_tag
        if t and not t.selected then
            t:view_only()
        end
        c:jump_to()
    end
end)








----------------------------------------------------------------------------------
