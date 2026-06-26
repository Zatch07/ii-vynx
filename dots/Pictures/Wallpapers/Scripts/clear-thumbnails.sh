#!/usr/bin/env bash

# This script clears the old thumbnails cache for your custom wallpaper picker.

CACHE_DIR="$HOME/.cache/wallpaper_picker/thumbs"

echo "Clearing thumbnail cache in $CACHE_DIR..."

if [ -d "$CACHE_DIR" ]; then
    rm -rf "$CACHE_DIR"/*
    echo "Thumbnail cache successfully cleared!"
else
    echo "Thumbnail cache directory ($CACHE_DIR) not found."
fi
