#!/bin/bash

# Exit on error
set -e

# Update system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
echo "Installing essential packages..."
sudo apt install -y \
    awesome \
    xorg \
    xinit \
    build-essential \
    git \
    curl \
    wget \
    network-manager \
    network-manager-gnome \
    alsa-utils \
    pulseaudio \
    pavucontrol \
    pnmixer \
    picom \
    copyq \
    redshift-gtk \
    xfce4-power-manager \
    safeeyes \
    bluez \
    bluez-tools \
    bluetooth \
    xbacklight \
    arandr \
    rofi \
    rofimoji \
    fonts-noto-color-emoji \
    thunar \
    thunar-archive-plugin \
    thunar-media-tags-plugin \
    xfce4-terminal \
    lxappearance \
    htop \
    uget \
    iw \
    vim

# Create necessary directories
echo "Creating config directories..."
mkdir -p ~/.config/awesome
mkdir -p ~/.config/picom

# Copy default awesome config
echo "Setting up AwesomeWM config..."
cp /etc/xdg/awesome/rc.lua ~/.config/awesome/

# Create picom config
echo "Creating picom config..."
cat > ~/.config/picom.conf << 'EOF'
# Shadow
shadow = true;
shadow-radius = 25;
shadow-opacity = 0.2;
shadow-offset-x = -30;
shadow-offset-y = -10;

shadow-exclude = [
    "! name~=''",
    "name = 'Notification'",
    "name = 'wbar'",
    "name = 'Docky'",
    "name = 'Kupfer'",
    "name = 'dropdown'",
    "name *= 'VirtualBox'",
    "name *= 'VLC'",
    "name *= 'Chromium'",
    "name *= 'Chrome'",
    "class_g ?= 'Xfce4-power-manager'",
    "window_type = 'desktop'",
    "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'",
    "_NET_WM_STATE@:32a *= '_NET_WM_STATE_MAXIMIZED_VERT'",
    "_GTK_FRAME_EXTENTS@:c"
];

# Fading
fading = true;
fade-in-step = 0.028;
fade-out-step = 0.03;
no-fading-destroyed-argb = true;

# Opacity
inactive-opacity = 1;
frame-opacity = 1;
inactive-opacity-override = false;
active-opacity = 1.0;

# Corners
corner-radius = 13;
rounded-corners-exclude = [
    "! name~=''",
    "class_g  = 'awesome'",
    "window_type = 'desktop'",
    "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'",
    "window_type = 'normal' && class_g != ''",
    "_NET_WM_STATE@:32a = '_NET_WM_STATE_MAXIMIZED_VERT'",
    "_NET_WM_STATE@:32a = '_NET_WM_STATE_MAXIMIZED_HORZ'"
];

# Backend
backend = "glx";
vsync = true;

# General Settings
mark-wmwin-focused = true;
mark-ovredir-focused = true;
detect-rounded-corners = true;
detect-client-opacity = true;
use-ewmh-active-win = true;
unredir-if-possible = true;
detect-transient = true;
detect-client-leader = true;
use-damage = true;
log-level = "warn";

# Window type settings
wintypes:
{
  dock = { shadow = false; };
  tooltip = { fade = false; shadow = false; };
  menu = { fade = true; };
  dropdown_menu = { fade = true; opacity = 1; };
  popup_menu = { fade = true; opacity = 1; };
};
EOF

# Create .xinitrc
echo "Creating .xinitrc..."
cat > ~/.xinitrc << EOF
#!/bin/bash

# Load X resources
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Start AwesomeWM
exec awesome
EOF

# Make .xinitrc executable
chmod +x ~/.xinitrc

# Create the autostart script
echo "Creating autostart script..."
cat > ~/.config/awesome/autostart.sh << EOF
#!/bin/bash

pkill picom
if ! pgrep -x "picom" > /dev/null; then
    picom --config ~/.config/picom.conf &
fi

syndaemon -i .5 -K -t -R -d &

setxkbmap -layout "us,ir" -option "grp:alt_shift_toggle" &

if ! pgrep -x "nm-applet" > /dev/null; then
    nm-applet &
fi

if ! pgrep -x "pnmixer" > /dev/null; then
    pnmixer &
fi

if ! pgrep -x "copyq" > /dev/null; then
    copyq &
fi

if ! pgrep -x "redshift-gtk" > /dev/null; then
    redshift-gtk &
fi

if ! pgrep -x "safeeyes" > /dev/null; then
    safeeyes &
fi

if ! pgrep -x "xfce4-power-manager" > /dev/null; then
    xfce4-power-manager &
fi

pavucontrol &

# Disable Caps Lock key
setxkbmap -option ctrl:nocaps
EOF

# Make autostart script executable
chmod +x ~/.config/awesome/autostart.sh

# Configure rofimoji
mkdir -p ~/.config/rofimoji
echo "Creating rofimoji config..."
cat > ~/.config/rofimoji/config << EOF
action = copy
selector = rofi
skin-tone = neutral
EOF

# Enable services
echo "Enabling services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

# Final message
echo "Installation complete!"
echo "You can now start X by typing 'startx'"
echo "Remember to add the autostart script to your AwesomeWM config (rc.lua)"
echo ""
echo "To use rofimoji:"
echo "1. Add this to your awesome config for keybinding:"
echo "   awful.key({ modkey }, 'e', function() awful.spawn('rofimoji') end,"
echo "   {description = 'emoji picker', group = 'launcher'}))"
