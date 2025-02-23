#!/bin/bash

# Directory for desktop files
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

# Function to create desktop file
create_desktop_file() {
    local app_path="$1"
    local name="$(basename "$app_path" | sed 's/\.[Aa]pp[Ii]mage$//' | sed 's/\.bin$//' | sed 's/_/ /g')"
    local filename="$(echo "$name" | tr '[:upper:]' '[:lower:]').desktop"

    # Convert only first letter of each word to uppercase
    local display_name="$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/\b\(.\)/\u\1/g')"

    cat > "$DESKTOP_DIR/$filename" << EOF
[Desktop Entry]
Name=$display_name
Exec=$app_path
Icon=$name
Type=Application
Categories=Application;
Terminal=false
EOF

    chmod +x "$app_path"
}

#~# Create desktop files for all applications
create_desktop_file "$HOME/D/setup/linux/krita.appimage"
create_desktop_file "$HOME/D/setup/linux/blender/blender"
create_desktop_file "$HOME/D/setup/linux/audacity.AppImage"
create_desktop_file "$HOME/D/setup/linux/avidemux.appimage"
create_desktop_file "$HOME/D/setup/linux/gimp.AppImage"
create_desktop_file "$HOME/D/setup/linux/glaxnimate.AppImage"
create_desktop_file "$HOME/D/setup/linux/HandBrake.AppImage"
create_desktop_file "$HOME/D/setup/linux/Inkscape.AppImage"
create_desktop_file "$HOME/D/setup/linux/kdenlive.AppImage"
create_desktop_file "$HOME/D/setup/linux/LosslessCut.AppImage"
create_desktop_file "$HOME/D/setup/linux/qView.AppImage"
create_desktop_file "$HOME/D/setup/linux/Supertuxkart.AppImage"
create_desktop_file "$HOME/D/setup/linux/unetbootin.bin"
create_desktop_file "$HOME/D/setup/linux/VPN/oblivion-desktop-linux-x64/oblivion-desktop"

echo "Desktop files created in $DESKTOP_DIR"
