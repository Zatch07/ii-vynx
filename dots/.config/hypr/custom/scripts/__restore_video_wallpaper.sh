#!/bin/bash
pkill -f -9 mpvpaper
pkill -f -9 linux-wallpaperengine
monitors=$(hyprctl monitors -j | jq -r '.[] | .name')
for monitor in $monitors; do
    nohup mpvpaper -o "no-audio loop hwdec=auto scale=bilinear interpolation=no video-sync=display-resample panscan=1.0 video-scale-x=1.0 video-scale-y=1.0 video-align-x=0.5 video-align-y=0.5 load-scripts=no" "$monitor" "/home/zatch/Pictures/Wallpapers/WallpaperEngine/Wuxia Warrior [WE-3636611023]/1765401944.mp4" >/dev/null 2>&1 &
    sleep 0.1
done
