# 🖼️ Wallpaper Engine Linux Setup Guide

This guide documents the steps taken to restore and optimize your Wallpaper Engine collection on Arch Linux.

## 📋 Overview of Work Done

1.  **Recovery & Sorting**:
    *   Recovered sorting logic from your `Seagate/arch-backup` history.
    *   Filtered 700+ items to keep only **Video** and **Scene** wallpapers.
    *   Organized them into `~/Pictures/Wallpapers/WallpaperEngine/` with proper naming conventions (`[WE-ID]`).

2.  **Player Installation**:
    *   Installed **`linux-wallpaperengine-git`** (for interactive Scenes).
    *   Installed **`mpvpaper-git`** (for high-performance Video wallpapers).

3.  **Asset Restoration**:
    *   Fixed the "Missing assets" error for the Scene player by moving the required shaders/data from `~/Downloads/assets/` to `/opt/linux-wallpaperengine/assets`.

4.  **Logic Integration**:
    *   Updated `switchwall.sh` in your active theme (`pacman-v2`) to automatically detect the wallpaper type.
    *   The script now chooses the best player (mpvpaper vs. linux-wallpaperengine) based on the `project.json` metadata.

5.  **Muting & Optimization**:
    *   Enforced **Silent Mode** across all wallpapers.
    *   Added `--silent` to Scene wallpapers and `no-audio` to Video wallpapers.

---

## 🚀 How to Use

### Sorting New Wallpapers
If you download more wallpapers to your Seagate drive, you can re-run your sorting script:
```bash
bash "/home/zatch/Pictures/Wallpaper Engine/sort-wallpapers.sh"
```

### Applying Wallpapers
Simply use your Quickshell wallpaper picker. The system will now:
1.  Detect if it's a Wallpaper Engine folder.
2.  Read the metadata.
3.  Launch the correct silent player.
4.  Generate system colors (Matugen) from the wallpaper's preview image.

## 🛠️ Troubleshooting

*   **Black Screen on Scenes**: Check if the assets are still in `/opt/linux-wallpaperengine/assets`.
*   **Video Playback Issues**: Ensure `mpvpaper` is installed and the monitor name (e.g., `DP-1`) is correctly detected by `hyprctl monitors`.
*   **Logs**: Check `~/.local/state/quickshell/user/generated/linux_we.log` for Scene errors.

---
*Created by Antigravity - 2026-05-13*
