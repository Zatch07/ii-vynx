#!/bin/bash

# Define your paths
# Source folder on the Seagate drive
WORKSHOP_DIR="/run/media/zatch/Seagate/431960"
# Destination folder in Pictures
DEST_DIR="$HOME/Pictures/Wallpapers/WallpaperEngine"

# Ensure the destination exists
mkdir -p "$DEST_DIR"

echo "🚀 Starting Wallpaper Engine sorting..."
echo "📂 Source: $WORKSHOP_DIR"
echo "📂 Destination: $DEST_DIR"
echo "------------------------------------------------"

# Counter for statistics
ADDED_COUNT=0
SKIPPED_COUNT=0

# Iterate through subdirectories in the Workshop folder
for dir in "$WORKSHOP_DIR"/*/ ; do
    [ -d "$dir" ] || continue
    
    # Every Wallpaper Engine folder MUST have a project.json
    if [ -f "${dir}project.json" ]; then
        
        # Extract type using jq (ensure it's installed)
        WP_TYPE=$(jq -r '.type' "${dir}project.json" 2>/dev/null)
        
        # Convert type to lowercase for robust comparison
        WP_TYPE_LOWER="${WP_TYPE,,}"
        
        # Filter logic: Only take "video" and "scene" wallpapers
        # This naturally excludes static "image" wallpapers (like .webp, .jpg, .png)
        if [[ "$WP_TYPE_LOWER" == "video" || "$WP_TYPE_LOWER" == "scene" ]]; then
            
            # Clean up the title for the filesystem (remove special characters)
            TITLE=$(jq -r '.title' "${dir}project.json" 2>/dev/null | tr -cd '[:alnum:] _-')
            
            # If title is empty or null, fallback to the folder ID
            [ -z "$TITLE" ] || [ "$TITLE" == "null" ] && TITLE="Wallpaper"
            
            ID=$(basename "$dir")
            
            # Destination path following the [WE-ID] naming convention
            DEST_LINK="${DEST_DIR}/${TITLE} [WE-${ID}]"
            
            # Copy the folder to the destination
            # Only copy if it doesn't already exist to save time
            if [ ! -d "$DEST_LINK" ]; then
                cp -r "$dir" "$DEST_LINK"
                echo "✅ Copied: $TITLE (Type: $WP_TYPE)"
                ((ADDED_COUNT++))
            else
                echo "⏭️  Skipped (Already exists): $TITLE"
                ((SKIPPED_COUNT++))
            fi
        else
            echo "❌ Skipped: $(basename "$dir") (Type: $WP_TYPE - Static Image)"
            ((SKIPPED_COUNT++))
        fi
    else
        echo "⚠️  Ignored: $(basename "$dir") (No project.json found)"
    fi
done

echo "------------------------------------------------"
echo "✨ Done!"
echo "📊 Added: $ADDED_COUNT"
echo "📊 Skipped: $SKIPPED_COUNT"
echo "🔗 Check your wallpapers here: $DEST_DIR"
