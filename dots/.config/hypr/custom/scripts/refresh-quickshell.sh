#!/bin/bash
# Refresh Quickshell components
# This script restarts the main bar and extra widgets.

# Kill existing processes
killall ydotool qs quickshell 2>/dev/null || :

# Wait a moment for cleanup
sleep 0.2

# 1. Main Bar
qs -c ii &

# 2. Skwd Tab Switcher
quickshell -p ~/.config/skwd &

# 3. Wallpaper Switcher
qs -p ~/.config/hypr/custom/wallpaperswitcher/wallpaperswitcher.qml &

echo "Quickshell components refreshed."
