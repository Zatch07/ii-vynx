#!/usr/bin/env bash
# generate_cursor_previews.sh
# Generates 32×32 PNG previews for every installed cursor theme and caches them
# at ~/.cache/cursor-previews/<theme-name>.png
# Output (stdout): one line per cursor theme in the format: name|/path/to/preview.png

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cursor-previews"
EXTRACTOR="$HOME/.local/bin/extract_cursor_preview.py"
mkdir -p "$CACHE_DIR"

# Collect unique cursor themes (de-duplicated by name) via associative array
declare -A SEEN_DIRS

# Define search paths
SEARCH_PATHS=(
    "$HOME/.icons"
    "$HOME/.local/share/icons"
    "/usr/share/icons"
    "$HOME/my-end4-dots/.icons"
)

# Also look for any .icons folder in home directory (depth 2)
while IFS= read -r extra_dir; do
    SEARCH_PATHS+=("$extra_dir")
done < <(find "$HOME" -maxdepth 2 -name ".icons" -type d 2>/dev/null)

for base_dir in "${SEARCH_PATHS[@]}"; do
    [ -d "$base_dir" ] || continue
    for theme_dir in "$base_dir"/*/; do
        [ -d "${theme_dir}cursors" ] || continue
        name=$(basename "$theme_dir")
        [ -z "${SEEN_DIRS["$name"]+x}" ] || continue
        SEEN_DIRS["$name"]="$theme_dir"
    done
done

# Sort names and emit output
for name in $(printf "%s\n" "${!SEEN_DIRS[@]}" | sort); do
    theme_dir="${SEEN_DIRS["$name"]}"
    cache_png="$CACHE_DIR/${name}.png"

    # 1. Use existing preview.png / cursor.png from the theme itself
    existing=$(find "$theme_dir" -maxdepth 3 \
        \( -name 'preview.png' -o -name 'cursor.png' \) 2>/dev/null | head -n 1)

    if [ -n "$existing" ]; then
        echo "${name}|${existing}"
        continue
    fi

    # 2. Use cached extracted preview if already present
    if [ -f "$cache_png" ]; then
        echo "${name}|${cache_png}"
        continue
    fi

    # 3. Extract from common cursor file names
    extracted=false
    for candidate in left_ptr default arrow crosshair top_left_arrow wait; do
        cursor_file="${theme_dir}cursors/${candidate}"
        if [ -f "$cursor_file" ]; then
            if python3 "$EXTRACTOR" "$cursor_file" "$cache_png" 32 2>/dev/null; then
                echo "${name}|${cache_png}"
                extracted=true
                break
            fi
        fi
    done

    # 4. No preview — emit empty path (UI shows fallback icon)
    if [ "$extracted" = false ]; then
        echo "${name}|"
    fi
done
