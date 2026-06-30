-- Custom environment variables
-- This file will not be overwritten across dots-hyprland updates.

hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or ""))

-- Caelestia Hoverboard extension environment variables
hl.env("CAELESTIA_LIB_DIR", os.getenv("HOME") .. "/.config/caelestia-hoverboard/build/lib")
hl.env("QML2_IMPORT_PATH", os.getenv("HOME") .. "/.config/caelestia-hoverboard/build/qml:$QML2_IMPORT_PATH")
hl.env("LD_LIBRARY_PATH", os.getenv("HOME") .. "/.config/caelestia-hoverboard/build/lib:$LD_LIBRARY_PATH")
