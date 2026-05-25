hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )

-- Thorium Browser
hl.bind("SUPER + B", hl.dsp.exec_cmd("thorium-browser-avx2"), { description = "App: Browser (Thorium)" })

-- Quickshell custom controls
hl.bind("CTRL + SUPER + B", hl.dsp.global("quickshell:barToggle"), { description = "Shell: Toggle bar" })
hl.bind("CTRL + SUPER + W", hl.dsp.global("quickshell:customWallpaperSelectorToggle"), { description = "Shell: Toggle custom wallpaper selector" })
hl.bind("CTRL + SUPER + ALT + W", hl.dsp.global("quickshell:customWallpaperSelectorRandom"), { description = "Shell: Select random wallpaper" })
hl.bind("CTRL + SUPER + M", hl.dsp.global("quickshell:mediaModeToggle"), { description = "Shell: Toggle media mode" })

-- Refresh script
hl.bind("CTRL + SUPER + R", hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/refresh-quickshell.sh"), { description = "Shell: Refresh Hyprland and Quickshell" })

-- Window Resizing (Arrows)
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.resize({ x = 50, y = 0 }), { repeating = true, description = "Window: Resize right" })
hl.bind("SUPER + SHIFT + Left", hl.dsp.window.resize({ x = -50, y = 0 }), { repeating = true })
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.resize({ x = 0, y = -50 }), { repeating = true, description = "Window: Resize up" })
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.resize({ x = 0, y = 50 }), { repeating = true })

-- Window Swapping (Arrows)
hl.bind("SUPER + ALT + Left", hl.dsp.window.move({ direction = "l", swap = true }))
hl.bind("SUPER + ALT + Right", hl.dsp.window.move({ direction = "r", swap = true }), { description = "Window: Swap" })
hl.bind("SUPER + ALT + Up", hl.dsp.window.move({ direction = "u", swap = true }), { description = "Window: Swap (Arrows)" })
hl.bind("SUPER + ALT + Down", hl.dsp.window.move({ direction = "d", swap = true }))

-- Workspace shift and follow
for i = 1, 10 do
    local numberkey = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
    local keyval = i % 10
    hl.bind("CTRL + SUPER + code:" .. numberkey[i], hl.dsp.exec_cmd("~/.local/bin/workspace-shift " .. keyval))
    hl.bind("SUPER + ALT + code:" .. numberkey[i], hl.dsp.exec_cmd("~/.local/bin/workspace-shift " .. keyval .. " && hyprctl dispatch workspace " .. keyval))
    hl.bind("SUPER + SHIFT + code:" .. numberkey[i], hl.dsp.window.move({ workspace = workspace_in_group(i), follow = true }))
end

-- Keypad numbers
for i = 1, 10 do
    local numpadkey = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }
    local keyval = i % 10
    hl.bind("CTRL + SUPER + code:" .. numpadkey[i], hl.dsp.exec_cmd("~/.local/bin/workspace-shift " .. keyval))
    hl.bind("SUPER + ALT + code:" .. numpadkey[i], hl.dsp.exec_cmd("~/.local/bin/workspace-shift " .. keyval .. " && hyprctl dispatch workspace " .. keyval))
    hl.bind("SUPER + SHIFT + code:" .. numpadkey[i], hl.dsp.window.move({ workspace = workspace_in_group(i), follow = true }))
end
