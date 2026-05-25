#!/usr/bin/env python3
"""
nighttab-update.py
Reads the current Matugen-generated colors.json, patches the nightTab base backup
with the correct primary hue and surface color, then outputs a ready-to-import file.

Run automatically by post-matugen.sh on every wallpaper change.
Output: ~/.config/matugen-custom/templates/thorium-nighttab/nighttab-current.json
Import this file in nightTab → Settings → Data → Import.
"""

import json, sys, math

import os

# Get the directory where the script is located
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

BASE    = os.path.join(BASE_DIR, "nighttab-base.json")
COLORS  = os.path.join(BASE_DIR, "colors.json")
OUTPUT  = os.path.join(BASE_DIR, "nighttab-current.json")

def hex_to_rgb(h):
    h = h.lstrip('#')
    return {'r': int(h[0:2],16), 'g': int(h[2:4],16), 'b': int(h[4:6],16)}

def rgb_to_hsl(rgb):
    r, g, b = rgb['r']/255, rgb['g']/255, rgb['b']/255
    mx, mn = max(r,g,b), min(r,g,b)
    l = (mx + mn) / 2
    if mx == mn:
        h = s = 0.0
    else:
        d = mx - mn
        s = d / (2 - mx - mn) if l > 0.5 else d / (mx + mn)
        if   mx == r: h = (g - b) / d + (6 if g < b else 0)
        elif mx == g: h = (b - r) / d + 2
        else:         h = (r - g) / d + 4
        h /= 6
    return {'h': round(h * 360), 's': round(s * 100), 'l': round(l * 100)}

try:
    with open(BASE)   as f: backup = json.load(f)
    with open(COLORS) as f: mc     = json.load(f)
except FileNotFoundError as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)

primary_rgb  = hex_to_rgb(mc['primary'])
surface_rgb  = hex_to_rgb(mc['surface'])
sc_rgb       = hex_to_rgb(mc['secondary_container'])
primary_hsl  = rgb_to_hsl(primary_rgb)
surface_hsl  = rgb_to_hsl(surface_rgb)

state = backup.get('state', backup)
theme = state['theme']

# The key setting: nightTab generates all 14 shades from this hue + saturation
theme['color']['range']['primary']['h'] = primary_hsl['h']
theme['color']['range']['primary']['s'] = min(primary_hsl['s'], 40)  # cap sat for readable shades

# Background solid color (surface)
theme['background']['color']['rgb'] = surface_rgb
theme['background']['color']['hsl'] = surface_hsl

# Accent color (primary)
theme['accent']['rgb'] = primary_rgb
theme['accent']['hsl'] = primary_hsl

with open(OUTPUT, 'w') as f:
    json.dump(backup, f, indent=2)

print(f"nightTab backup updated → {OUTPUT}")
print(f"  Primary hue: {primary_hsl['h']}°  |  Surface: {mc['surface']}  |  Accent: {mc['primary']}")
