#!/usr/bin/env bash

# This script manually triggers the thumbnail generation for your wallpaper picker.
# It simply calls the existing startup script you have in hypr/custom.

echo "Running your custom wallpaper thumbnail generator..."
~/.config/hypr/custom/scripts/generate-wallpaper-thumbs.sh
echo "Done!"
