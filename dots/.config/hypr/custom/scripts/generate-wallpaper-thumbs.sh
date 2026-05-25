#!/usr/bin/env bash
# generate-wallpaper-thumbs.sh
# Generates 1280x720 (720p) JPEG thumbnails for the slanted wallpaper picker.
# - Static images: ImageMagick (resize to fit, then pad to exact 720p)
# - Video files:   ffmpeg first-frame extraction
# Only generates thumbnails for NEW files — existing ones are skipped.
# Usage: ./generate-wallpaper-thumbs.sh [--wall-dir <path>]

WALL_DIR="${HOME}/Pictures/Wallpapers"
THUMB_DIR="${HOME}/.cache/wallpaper_picker/thumbs"

# Thumbnail dimensions (720p — crisp at 300x420 card size with 1.15x focus scale)
THUMB_W=1280
THUMB_H=720

while [[ $# -gt 0 ]]; do
    case "$1" in
        --wall-dir|-d)
            WALL_DIR="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

mkdir -p "$THUMB_DIR"

process_image() {
    local src="$1"
    local name
    name="$(basename "$src")"
    local thumb="${THUMB_DIR}/${name}.jpg"

    if [ -f "$thumb" ]; then
        return 0
    fi

    echo "Thumbing: $name"
    # Added 'nice -n 10' right before 'magick'
    nice -n 10 magick "$src" \
        -resize "${THUMB_W}x${THUMB_H}" \
        -background black \
        -gravity center \
        -extent "${THUMB_W}x${THUMB_H}" \
        -quality 88 \
        "$thumb" 2>/dev/null
    echo "FILE $thumb"
}

process_video() {
    local src="$1"
    local name
    name="$(basename "$src")"
    local thumb="${THUMB_DIR}/000_${name}.jpg"

    if [ -f "$thumb" ]; then
        return 0
    fi

    echo "Thumbing video: $name"
    # Added 'nice -n 10' right before 'ffmpeg'
    nice -n 10 ffmpeg -y -ss 00:00:01 -i "$src" \
        -vframes 1 \
        -vf "scale=${THUMB_W}:${THUMB_H}:force_original_aspect_ratio=decrease,pad=${THUMB_W}:${THUMB_H}:(ow-iw)/2:(oh-ih)/2:black" \
        -q:v 3 \
        "$thumb" 2>/dev/null
    echo "FILE $thumb"
}

IMAGE_EXTS=("jpg" "jpeg" "png" "webp" "avif" "bmp")
VIDEO_EXTS=("mp4" "webm" "mkv" "mov" "avi")

shopt -s nullglob nocaseglob

# Calculate 50% of available CPU cores
MAX_JOBS=$(( $(nproc) / 2 ))
[[ $MAX_JOBS -lt 1 ]] && MAX_JOBS=1

# Run conversions with limited parallelism (50% CPU bounds) and lowered scheduling priority
job_count=0

for ext in "${IMAGE_EXTS[@]}"; do
    for f in "${WALL_DIR}"/*.${ext}; do
        [ -f "$f" ] || continue
        # Call the function directly in the background
        process_image "$f" &
        ((job_count++))
        if (( job_count >= MAX_JOBS )); then
            wait -n
            ((job_count--))
        fi
    done
done

for ext in "${VIDEO_EXTS[@]}"; do
    for f in "${WALL_DIR}"/*.${ext}; do
        [ -f "$f" ] || continue
        # Call the function directly in the background
        process_video "$f" &
        ((job_count++))
        if (( job_count >= MAX_JOBS )); then
            wait -n
            ((job_count--))
        fi
    done
done

wait
echo "All thumbnails generated safely in ${THUMB_DIR}."
