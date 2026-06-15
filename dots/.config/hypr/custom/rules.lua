-- Custom window and layer rules
-- This file will not be overwritten across dots-hyprland updates.

hl.window_rule({match = {class = "^(vesktop)$" }, workspace = 1 })
hl.window_rule({match = {class = "^(discord)$" }, workspace = 1 })
hl.window_rule({match = {class = "^(Ferdium)$" }, workspace = 1 })

-- Hoverboard Rules
hl.layer_rule({ match = { namespace = "caelestia-dashboard-overlay" }, blur = true })
hl.layer_rule({ match = { namespace = "caelestia-dashboard-overlay" }, ignore_alpha = 0 })

-- Showoff apps rules
math.randomseed(os.time())

local known_sizes = {
    ["cmatrix"] = {593, 404},
    ["cbonsai"] = {578, 584},
    ["pipes.sh"] = {460, 222},
    ["cava"] = {612, 289},
    ["asciiquarium"] = {600, 400},
    ["rain.sh"] = {350, 600},
    ["terminal-rain"] = {350, 600}
}

local showoff_apps = {}
local apps_f = io.open(os.getenv("HOME") .. "/showapps.txt", "r")
if apps_f then
    for raw_line in apps_f:lines() do
        local line = raw_line:match("^%s*(.-)%s*$")
        if line and line ~= "" then
            local size = known_sizes[line] or {550, 400}
            table.insert(showoff_apps, {name = line, size = size})
        end
    end
    apps_f:close()
end

local function get_overlap_area(R1, R2)
    local left = math.max(R1.x, R2.x)
    local right = math.min(R1.x + R1.w, R2.x + R2.w)
    local top = math.max(R1.y, R2.y)
    local bottom = math.min(R1.y + R1.h, R2.y + R2.h)
    
    if left < right and top < bottom then
        return (right - left) * (bottom - top)
    end
    return 0
end

local screen_w, screen_h = 1920, 1080
local f = io.open("/tmp/hypr_monitor_dim.txt", "r")
if f then
    local w = f:read("*l")
    local h = f:read("*l")
    if w and h then
        screen_w = tonumber(w) or 1920
        screen_h = tonumber(h) or 1080
    end
    f:close()
end

local placed_boxes = {}

for _, app in ipairs(showoff_apps) do
    local best_x, best_y = 0, 0
    local found_good_spot = false
    local w, h = app.size[1], app.size[2]
    
    for attempt = 1, 50 do
        local pct_x = math.random(2, 65) / 100
        local pct_y = math.random(5, 55) / 100
        
        local candidate = { x = pct_x * screen_w, y = pct_y * screen_h, w = w, h = h }
        local valid = true
        
        for _, placed in ipairs(placed_boxes) do
            local overlap = get_overlap_area(candidate, placed)
            if (overlap / (w * h) > 0.15) or (overlap / (placed.w * placed.h) > 0.15) then
                valid = false
                break
            end
        end
        
        if valid then
            best_x, best_y = pct_x, pct_y
            found_good_spot = true
            placed_boxes[#placed_boxes + 1] = candidate
            break
        end
        best_x, best_y = pct_x, pct_y
    end
    
    if not found_good_spot then
        placed_boxes[#placed_boxes + 1] = { x = best_x * screen_w, y = best_y * screen_h, w = w, h = h }
    end

    hl.window_rule({
        match = {title = "^showoff_" .. app.name .. "$"},
        float = true,
        size = app.size,
        move = {"(monitor_w*" .. best_x .. ")", "(monitor_h*" .. best_y .. ")"}
    })
end
