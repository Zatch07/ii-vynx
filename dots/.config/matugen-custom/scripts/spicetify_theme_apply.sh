#!/usr/bin/env bash

# This script is triggered by Matugen to refresh Spotify's theme colors
# based on your current wallpaper.
# Reimagined for pure Matugen Colors synchronicity.

# Get the current settings
theme=$(spicetify config current_theme)
extensions=$(spicetify config extensions || true)

# Remove dynamic extensions if they exist to rely strictly on Matugen
if [[ "$extensions" == *"Vibrant.min.js"* ]] || [[ "$extensions" == *"deluxified.js"* ]]; then
  spicetify config extensions ""
  modified_extensions=1
fi

# Check if the theme is already set to skwd
if [[ "$theme" != "skwd" ]] || [[ "$modified_extensions" == "1" ]]; then
  # First time setup or extension change: full apply required
  spicetify config current_theme skwd
  spicetify apply
else
  # Use 'refresh -s' to update styles/colors without restarting the app instantly
  spicetify refresh -s
fi