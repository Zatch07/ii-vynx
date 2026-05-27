-- Custom keybinds
-- This file will not be overwritten across dots-hyprland updates.

-- Unbind defaults to prevent conflicts
hl.unbind("SUPER + B")
hl.unbind("CTRL + SUPER + R")
hl.unbind("SUPER + SHIFT + Left")
hl.unbind("SUPER + SHIFT + Right")
hl.unbind("SUPER + SHIFT + Up")
hl.unbind("SUPER + SHIFT + Down")
hl.unbind("CTRL + SUPER + T")
hl.unbind("CTRL + SUPER + ALT + T")
hl.unbind("SUPER + SUPER_L")
hl.unbind("SUPER + SUPER_R")
hl.unbind("SUPER + J")

-- Unbind workspace conflicts
for i = 1, 10 do
    local numberkey = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
    local numpadkey = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }
    hl.unbind("SUPER + ALT + code:" .. numberkey[i])
    hl.unbind("SUPER + ALT + code:" .. numpadkey[i])
    hl.unbind("SUPER + SHIFT + code:" .. numberkey[i])
    hl.unbind("SUPER + SHIFT + code:" .. numpadkey[i])
end

-- Custom app keybinds
hl.bind("CTRL+SUPER+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/illogical-impulse/config.json"), {description = "Edit shell config"} )
hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )
hl.bind("SUPER + B", hl.dsp.exec_cmd("thorium-browser-avx2"), { description = "App: Browser (Thorium)" })

-- Launcher (Alt + Grave)
hl.bind("ALT + grave", hl.dsp.global("quickshell:searchToggle"), { description = "Shell: Toggle search" })
hl.bind("ALT + grave", hl.dsp.exec_cmd("qs -c $qsConfig ipc call TEST_ALIVE || pkill fuzzel || fuzzel"))

-- Skwd Window Switcher
hl.bind("ALT + Tab", hl.dsp.exec_cmd("bash -c 'echo \"switcherNext\" > ${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/skwd/cmd'"), { description = "Window: Switch next" })
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("bash -c 'echo \"switcherPrev\" > ${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/skwd/cmd'"), { description = "Window: Switch prev" })

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
    hl.bind("SUPER + ALT + code:" .. numberkey[i], hl.dsp.exec_cmd("~/.local/bin/workspace-shift " .. keyval .. " && hyprctl dispatch 'hl.dsp.focus({ workspace = " .. keyval .. " })'"))
    hl.bind("SUPER + SHIFT + code:" .. numberkey[i], function()
        hl.dispatch(hl.dsp.window.move({ workspace = workspace_in_group(i), follow = true }))
    end)
end

-- Keypad numbers
for i = 1, 10 do
    local numpadkey = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }
    local keyval = i % 10
    hl.bind("CTRL + SUPER + code:" .. numpadkey[i], hl.dsp.exec_cmd("~/.local/bin/workspace-shift " .. keyval))
    hl.bind("SUPER + ALT + code:" .. numpadkey[i], hl.dsp.exec_cmd("~/.local/bin/workspace-shift " .. keyval .. " && hyprctl dispatch 'hl.dsp.focus({ workspace = " .. keyval .. " })'"))
    hl.bind("SUPER + SHIFT + code:" .. numpadkey[i], function()
        hl.dispatch(hl.dsp.window.move({ workspace = workspace_in_group(i), follow = true }))
    end)
end
