if status is-interactive
    # Commands to run in interactive sessions can go here
end

function bepass
    cd ~/D/setup/linux/VPN/bepass/
    ./bepass
end

function warp
    cd ~/D/setup/linux/VPN/Warp-plus/
    ./warp-plus
end

function wp
    cd ~/D/setup/linux/VPN/Warp-plus/
    ./warp-plus --gool
end

function wp6
    cd ~/D/setup/linux/VPN/Warp-plus/
    ./warp-plus -6 --gool
end

function wps
    cd ~/D/setup/linux/VPN/Warp-plus/
    ./warp-plus --scan
end

function wpe
    cd ~/D/setup/linux/VPN/Warp-plus/
    ./warp-plus -e [2606:4700:d1::c993:5abb:1a22:99d9]:1002
end

function ws
    cd ~/D/setup/linux/VPN/Warp-plus/
    ./warp-plus --cfon --country DE
end

function red
    sudo redshift -l 35.7:51.26 -t 5700:3600 -g 0.8 -m randr -v
end

function r
    ssh -p 2222 -i ~/.ssh/id_rsa redpis5@213.165.242.8
end
function image
    fzf --preview 'chafa {}'
end
function video
    set selected_file (fzf)
    if test -n "$selected_file"
        mpv "$selected_file"
    end
end
# Set up fzf key bindings
fzf --fish | source


set -x PATH "$HOME/.local/bin" $PATH
set -x PATH "/opt/nvim-linux64/bin" $PATH

