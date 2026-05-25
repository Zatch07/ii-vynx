#!/bin/bash
# Post-Matugen hook script
# This script handles Spicetify and GTK theme refreshing.

# 1. Spicetify reload
if command -v spicetify >/dev/null 2>&1 && [ -d "$HOME/.config/spicetify/Themes/wal" ]; then
    spicetify apply -n || spicetify restore backup apply
    hyprctl dispatch sendshortcut "CTRL SHIFT, R, class:^(Spotify)$" || :
fi

# 2. Refresh GTK theme (triggers apps like Thorium to pick up new colors)
current_theme=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "\"'")
if [ -n "$current_theme" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "wrong-theme"
    gsettings set org.gnome.desktop.interface gtk-theme "$current_theme"
fi

# 3. Reload Kitty
killall -USR1 kitty 2>/dev/null || :

# 4. Update nightTab backup with current Matugen colors
python3 ~/.config/matugen-custom/templates/thorium-nighttab/nighttab-update.py 2>/dev/null || :
python3 ~/my-end4-dots/thorium-nighttab/nighttab-update.py 2>/dev/null || :
