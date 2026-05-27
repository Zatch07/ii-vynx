-- Custom environment variables
-- This file will not be overwritten across dots-hyprland updates.

hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or ""))
