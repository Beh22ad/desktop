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
local batteryarc_widget = require("batteryarc")
local logout_menu_widget = require("logout-menu")
----------------------------------------------------------------
-- change color of each tag
--local original_taglist_label = awful.widget.taglist.taglist_label
--local tag_colors_b = { "#3a3f50", "#3a3a50", "#3f3a50", "#453a50",
--  "#4b3b51", "#4a3a50", "#503a50", "#503a4a", "#503a45" }
--local tag_colors_s = { "#606a85", "#606085", "#6a6085", "#736085",
--  "#7b6085", "#7c6085", "#856085", "#85607c", "#856073" }
--function awful.widget.taglist.taglist_label(tag, args, tb)
--  local idx = (tag.index - 1) % #tag_colors_b + 1
--  local args = {bg_focus = tag_colors_s[idx]}
--  local text, bg, bg_image, icon, other_args =
--    original_taglist_label(tag, args, tb)
--  if bg == nil then
--    bg = tag_colors_b[idx]
--  end
--  return text, bg, bg_image, icon, other_args
--end
--------------------------------------------------------------------
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

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/theme.lua")

--! Run autostart.sh
awful.spawn.with_shell("~/.config/awesome/autorun.sh")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
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
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal, home .. "/.icons/Papirus/32x32/apps/Terminal.svg"}
local LosslessCut = { "LosslessCut", function() awful.util.spawn_with_shell("~/D/setup/linux/LosslessCut.AppImage") end, home .. "/.icons/Papirus/32x32/apps/losslesscut.svg" }
local Inkscape = { "Inkscape", function() awful.util.spawn_with_shell("~/D/setup/linux/Inkscape.AppImage") end, home .. "/.icons/Papirus/32x32/apps/inkscape.svg" }
local Gimp = { "Gimp", function() awful.util.spawn_with_shell("~/D/setup/linux/gimp.AppImage") end, home .. "/.icons/Papirus/32x32/apps/gimp.svg" }
local Krita = { "Krita", function() awful.util.spawn_with_shell("~/D/setup/linux/krita.appimage") end, home .. "/.icons/Papirus/32x32/apps/krita.svg" }
local kdenlive = { "kdenlive", function() awful.util.spawn_with_shell("~/D/setup/linux/kdenlive.AppImage") end, home .. "/.icons/Papirus/32x32/apps/kdenlive.svg" }
local HandBrake = { "HandBrake", function() awful.util.spawn_with_shell("~/D/setup/linux/HandBrake.AppImage") end, home .. "/.icons/Papirus/32x32/apps/fr.handbrake.ghb.svg" }
local Supertuxkart = { "Supertuxkart", function() awful.util.spawn_with_shell("~/D/setup/linux/Supertuxkart.AppImage") end, home .. "/.icons/Papirus/32x32/apps/supertuxkart.svg" }
local Calculator = { "Calculator", function() awful.util.spawn_with_shell("galculator") end, home .. "/.icons/Papirus/32x32/apps/galculator.svg" }
local Exit = { "Exit", "bl-exit", home .. "/.icons/Papirus/32x32/apps/deepin-crossover.svg" }


--if has_fdo then
--   mymainmenu = freedesktop.menu.build({
--       before = { menu_awesome },
--        after =  { menu_terminal }
--    })
--else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  LosslessCut,
                  Inkscape,
                  Gimp,
                  Krita,
                  kdenlive,
                  HandBrake,
                  Calculator,
                  Supertuxkart,
                  { "Debian", debian.menu.Debian_menu.Debian },

                 menu_terminal,
                 Exit,
                }
    })
--end


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

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
    local color = "#FFDAF7"
    if layout == " ir " or layout == "🇮🇷" then
        color = "#00FF00"  -- Green for "ir"
        mykeyboardlayout.widget:set_markup('<span font="sans bold 12" color="' .. color .. '">🇮🇷</span>')
	else
		 mykeyboardlayout.widget:set_markup('<span font="sans bold 12" color="' .. color .. '">🇺🇸</span>')
	end
--	 naughty.notify({ title = "Unexpected Layout", text = "|"..layout.."|", timeout = 0 })
 --   mykeyboardlayout.widget:set_markup('<span font="sans bold 12" color="' .. color .. '">' .. layout .. '</span>')

end

-- Connect the function to the signal that is triggered when the layout changes
mykeyboardlayout:connect_signal("widget::redraw_needed", function()
    update_keyboard_layout()
end)

-- Initial update
update_keyboard_layout()



-- {{{ Wibar
-- Create a textclock widget
-- mytextclock = wibox.widget.textclock()

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
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
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




-- Farsi date
local data_textbox = wibox.widget.textbox()
data_textbox:set_markup('<span font="Vazirmatn 10" foreground="#FFDAF7">...</span>')

local function update_data()
    awful.spawn.easy_async([[bash -c "~/D/setup/linux/xfce/full-data.sh"]], function(stdout)
        -- Trim any trailing newlines or spaces
        local trimmed_output = stdout:gsub("^%s*(.-)%s*$", "%1")
        -- Update the data_textbox with the correct font and color
        data_textbox:set_markup(string.format('<span font="Vazirmatn 10" foreground="#FFDAF7">%s</span>', trimmed_output))
    end)
end

update_data()

gears.timer {
    timeout   = 60,
    call_now  = true,
    autostart = true,
    callback  = update_data
}




-- Tehran themprature
    local temprature_textbox = wibox.widget.textbox()
    temprature_textbox:set_markup('<span font="Vazirmatn 10" foreground="#98FB98">...</span>')
    local temprature_widget = wibox.container.margin(temprature_textbox, 5, 5, 5, 5)
    local function update_temprature()
    awful.spawn.easy_async([[bash -c "~/D/setup/linux/xfce/weather-fa2.sh "]], function(stdout)
		local trimmed_output = stdout:gsub("^%s*(.-)%s*$", "%1")
        -- Update the data_textbox with the correct font and color
        temprature_textbox:set_markup(string.format('<span font="Vazirmatn 11" foreground="#FFDAF7">%s</span>', trimmed_output))
		end)
	end
	update_temprature()
	gears.timer {
		timeout   = 300,
		call_now  = true,
		autostart = true,
		callback  = update_temprature
	}

-- download data meter
    local download_textbox = wibox.widget.textbox()
    download_textbox:set_markup('<span font="Vazirmatn 11" foreground="#FFDAF7">...</span>')
    local download_widget = wibox.container.margin(download_textbox, 5, 5, 5, 5)
    local function update_download()
    awful.spawn.easy_async([[bash -c "~/D/setup/linux/xfce/download-meter-raw.sh"]], function(stdout)
        local trimmed_output = stdout:gsub("^%s*(.-)%s*$", "%1")
        -- Update the data_textbox with the correct font and color
        download_textbox:set_markup(string.format('<span font="Vazirmatn 10" foreground="#FFDAF7">%s</span>', trimmed_output))
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
time_widget.markup = '<span color="#FFDAF7" font="10">Time</span>'

--date_widget.font =10
date_widget.markup = '<span color="#FFDAF7" font="Bold 12">Date</span>'

-- Create a function to update time
local function update_time()
    local time_text = os.date("%H:%M")
    time_widget.markup = '<span color="#FFDAF7" font="10">' .. time_text .. '</span>'
end

-- Create a function to update date
local function update_date()
    local date_text = os.date(" %B \n %Y/%m/%d ")
    date_widget.markup = '<span color="#FFDAF7" font="Bold 12">' .. date_text .. '</span>'
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
        position = "top_right",
        margin = 10,
        width = 200,
        height = 70,
        font = "Sans Bold 12",
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
        awful.button({ }, 3, function()
            awful.menu.client_list({ theme = { width = 250 } })
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
mysystray = wibox.widget.systray()
mysystray:set_base_size(18)
local mysystray_widget = wibox.container.margin(mysystray, 5, 2, 5, 0)






-- Use this function to create the tasklist for each screen
s.mytasklist = create_tasklist_widget(s)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
          --  mylauncher,

            s.mytaglist,
           _,centered_layoutbox, _,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,

            { -- Keyboard layout widget container
				layout = wibox.layout.fixed.vertical,
			--	mykeyboardlayout,
			keyboard_box,
			},
			batteryarc_widget({
						show_notification_mode = "on_click",
						show_current_level = true,
						arc_thickness = 2,
						size=15,
					}),
            mysystray_widget,
            temprature_widget,
            download_widget,
            data_textbox,
            time_date_widget,
            --mytextclock,

            logout_menu_widget{
            font = 'Play 14',
            onlock = function() awful.spawn.with_shell('i3lock-fancy') end
        }

        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

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
     awful.key({ modkey },            ".",     function () awful.util.spawn_with_shell("~/.local/bin/rofimoji --hidden-descriptions") end,
              {description = "rofimoji", group = "launcher"}),

	  awful.key({ modkey },            "Up",     function () awful.util.spawn_with_shell("amixer set Master 5%+") end,{description = "Volume+", group = "client"}),
	   awful.key({ modkey },            "Down",     function () awful.util.spawn_with_shell("amixer set Master 5%-") end,{description = "Volume-", group = "client"}),

	   awful.key( {}, "Scroll_Lock",     function () awful.util.spawn_with_shell("xbacklight -set 30") end,{description = "brightness up ", group = "client"}),

	   awful.key({ modkey },            "Scroll_Lock",     function () awful.util.spawn_with_shell("xbacklight -set 0") end,{description = "brightness off", group = "client"}),

	   awful.key({  },            "Print",     function () awful.util.spawn_with_shell("flameshot gui") end,{description = "Screen shot", group = "client"}),

	   awful.key({ modkey },     " "    ,     function () awful.util.spawn_with_shell("jgmenu_run") end,{description = "Menu", group = "client"}),
	   awful.key({ modkey },       "h"     ,     function () awful.util.spawn_with_shell("x-terminal-emulator -T 'htop task manager' -e htop") end,{description = "Htop", group = "client"}),
	   awful.key({ modkey },       "Escape"     ,     function () awful.util.spawn_with_shell("systemctl suspend") end,{description = "sleep", group = "client"}),
	   awful.key({ modkey },       "v"     ,     function () awful.util.spawn_with_shell("xfce4-clipman-history") end,{description = "Clip board", group = "client"}),





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
          "Pavucontrol",
          "mother.py",
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

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
     { rule = { class = "Thunar" },
       properties = { screen = 1, tag = "2" } },
     { rule = { class = "Google-chrome" },
       properties = { screen = 1, tag = "1" } },
     { rule = { class = "Geany" },
       properties = { screen = 1, tag = "3" } },
       { rule = { class = "Pavucontrol" },
       properties = { screen = 1, tag = "9" } },
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
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- border for active windows only

beautiful.gap_single_client   = false
screen.connect_signal("arrange", function (s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width -- your border width
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
