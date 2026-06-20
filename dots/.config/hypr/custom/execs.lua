-- Custom startup applications
-- This file will not be overwritten across dots-hyprland updates.

hl.on("hyprland.start", function()
    hl.exec_cmd("bash -c 'discord-canary --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer --enable-gpu-rasterization --enable-zero-copy'")
    -- hl.exec_cmd("bash -c 'sleep 3 && vesktop'")
    hl.exec_cmd("jamesdsp --tray")
    hl.exec_cmd("valent --gapplication-service")
    hl.exec_cmd("bash -c 'sleep 5 && ~/.config/hypr/custom/scripts/generate-wallpaper-thumbs.sh'")
    hl.exec_cmd("~/.config/hypr/custom/scripts/refresh-quickshell.sh")
    hl.exec_cmd("sleep 0.5 && ~/.config/qylock/smart_lock.sh --startup")
    hl.exec_cmd("surge server start")
    -- hl.exec_cmd("localsend --hidden")
    hl.exec_cmd("bash -c 'sleep 3 && ferdium'")
end)

