#!/usr/bin/env -S /bin/sh -c "source \$(eval echo \$ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate&&exec python -E \"\$0\" \"\$@\""
import argparse
import re
import os
from os.path import expandvars as os_expandvars
from typing import Dict, List

TITLE_REGEX = r"^(?:#+|--#+)!"
HIDE_COMMENT = "[hidden]"
MOD_SEPARATORS = ['+', ' ']
COMMENT_BIND_PATTERN = "#/#"

parser = argparse.ArgumentParser(description='Hyprland keybind reader')
parser.add_argument('--path', type=str, default="$HOME/.config/hypr/hyprland.conf", help='path to keybind file (sourcing isn\'t supported)')
args = parser.parse_args()
content_lines = []
reading_line = 0

Variables: Dict[str, str] = {}


class KeyBinding(dict):
    def __init__(self, mods, key, dispatcher, params, comment) -> None:
        self["mods"] = mods
        self["key"] = key
        self["dispatcher"] = dispatcher
        self["params"] = params
        self["comment"] = comment

class Section(dict):
    def __init__(self, children, keybinds, name) -> None:
        self["children"] = children
        self["keybinds"] = keybinds
        self["name"] = name


def read_content(path: str) -> str:
    if (not os.access(os.path.expanduser(os.path.expandvars(path)), os.R_OK)):
        return ("error")
    with open(os.path.expanduser(os.path.expandvars(path)), "r") as file:
        return file.read()


def autogenerate_comment(dispatcher: str, params: str = "") -> str:
    match dispatcher:

        case "resizewindow":
            return "Resize window"

        case "movewindow":
            if(params == ""):
                return "Move window"
            else:
                return "Window: move in {} direction".format({
                    "l": "left",
                    "r": "right",
                    "u": "up",
                    "d": "down",
                }.get(params, "null"))

        case "pin":
            return "Window: pin (show on all workspaces)"

        case "splitratio":
            return "Window split ratio {}".format(params)

        case "togglefloating":
            return "Float/unfloat window"

        case "resizeactive":
            return "Resize window by {}".format(params)

        case "killactive":
            return "Close window"

        case "fullscreen":
            return "Toggle {}".format(
                {
                    "0": "fullscreen",
                    "1": "maximization",
                    "2": "fullscreen on Hyprland's side",
                }.get(params, "null")
            )

        case "fakefullscreen":
            return "Toggle fake fullscreen"

        case "workspace":
            if params == "+1":
                return "Workspace: focus right"
            elif params == "-1":
                return "Workspace: focus left"
            return "Focus workspace {}".format(params)

        case "movefocus":
            return "Window: move focus {}".format(
                {
                    "l": "left",
                    "r": "right",
                    "u": "up",
                    "d": "down",
                }.get(params, "null")
            )

        case "swapwindow":
            return "Window: swap in {} direction".format(
                {
                    "l": "left",
                    "r": "right",
                    "u": "up",
                    "d": "down",
                }.get(params, "null")
            )

        case "movetoworkspace":
            if params == "+1":
                return "Window: move to right workspace (non-silent)"
            elif params == "-1":
                return "Window: move to left workspace (non-silent)"
            return "Window: move to workspace {} (non-silent)".format(params)

        case "movetoworkspacesilent":
            if params == "+1":
                return "Window: move to right workspace"
            elif params == "-1":
                return "Window: move to right workspace"
            return "Window: move to workspace {}".format(params)

        case "togglespecialworkspace":
            return "Workspace: toggle special"

        case "exec":
            return "Execute: {}".format(params)

        case _:
            return ""

def get_keybind_at_line(line_number, line_start = 0):
    global content_lines
    line = content_lines[line_number]
    _, keys = line.split("=", 1)
    keys, *comment = keys.split("#", 1)

    mods, key, dispatcher, *params = list(map(str.strip, keys.split(",", 4)))
    params = "".join(map(str.strip, params))

    # Remove empty spaces
    comment = list(map(str.strip, comment))
    # Add comment if it exists, else generate it
    if comment:
        comment = comment[0]
        if comment.startswith("[hidden]"):
            return None
    else:
        comment = autogenerate_comment(dispatcher, params)

    if mods:
        modstring = mods + MOD_SEPARATORS[0] # Add separator at end to ensure last mod is read
        mods = []
        p = 0
        for index, char in enumerate(modstring):
            if(char in MOD_SEPARATORS):
                if(index - p > 1):
                    mods.append(modstring[p:index])
                p = index+1
    else:
        mods = []

    # Casing normalization for mods to match QML
    mod_mapping = {
        "ctrl": "Ctrl",
        "control": "Ctrl",
        "super": "Super",
        "alt": "Alt",
        "mod1": "Alt",
        "shift": "Shift"
    }
    normalized_mods = [mod_mapping.get(m.lower(), m) for m in mods]

    return KeyBinding(normalized_mods, key, dispatcher, params, comment)

def get_keybind_at_line_lua(line_text):
    line = line_text.strip()
    
    # We match hl.bind("keys", dispatcher, {options}) or hl.bind("keys", dispatcher)
    # The regex allows semi-colon at the end, and optional trailing comments
    match = re.match(r'^hl\.bind\(\s*"([^"]+)"\s*,\s*(.*?)\s*(?:,\s*\{\s*(.*?)\s*\})?\s*\);?(?:\s*--.*)?$', line)
    if not match:
        return None
    
    keys_part = match.group(1).strip()
    dispatcher = match.group(2).strip()
    options_part = match.group(3) or ""
    
    # Extract description from options
    desc_match = re.search(r'description\s*=\s*"([^"]+)"', options_part)
    comment = desc_match.group(1).strip() if desc_match else ""
    
    if not comment or comment.startswith("[hidden]"):
        return None
    
    # Normalize mods and key
    dispatcher_part = match.group(2).strip()
    if dispatcher_part.startswith('"'):
        # Two-string signature: hl.bind("MODS", "KEY", ...)
        second_arg_match = re.match(r'^"([^"]+)"\s*,\s*(.*)$', dispatcher_part)
        if second_arg_match:
            key = second_arg_match.group(1).strip()
            mods = [m.strip() for m in keys_part.split('+') if m.strip()]
        else:
            mods_and_key = [m.strip() for m in keys_part.split('+')]
            mods = [m.strip() for m in mods_and_key[:-1] if m.strip()]
            key = mods_and_key[-1].strip()
    else:
        # Single-string signature: hl.bind("MODS + KEY", ...)
        mods_and_key = [m.strip() for m in keys_part.split('+')]
        mods = [m.strip() for m in mods_and_key[:-1] if m.strip()]
        key = mods_and_key[-1].strip()
    
    # Casing normalization for mods to match QML
    mod_mapping = {
        "ctrl": "Ctrl",
        "control": "Ctrl",
        "super": "Super",
        "alt": "Alt",
        "mod1": "Alt",
        "shift": "Shift"
    }
    normalized_mods = [mod_mapping.get(m.lower(), m) for m in mods]
    
    return KeyBinding(normalized_mods, key, "exec", dispatcher, comment)

def get_binds_recursive(current_content, scope, is_lua=False):
    global content_lines
    global reading_line
    while reading_line < len(content_lines):
        line = content_lines[reading_line].strip()
        heading_search_result = re.search(TITLE_REGEX, line)
        if heading_search_result:
            # Determine scope
            heading_scope = line.count('#')
            
            if(heading_scope <= scope):
                reading_line -= 1
                return current_content

            section_name = line[(line.find('!')+1):].strip()
            reading_line += 1
            current_content["children"].append(get_binds_recursive(Section([], [], section_name), heading_scope, is_lua))

        elif is_lua:
            if line.lstrip().startswith("hl.bind"):
                full_line = line
                offset = 0
                while full_line.count('(') > full_line.count(')'):
                    offset += 1
                    if reading_line + offset >= len(content_lines):
                        break
                    full_line += " " + content_lines[reading_line + offset].strip()
                
                keybind = get_keybind_at_line_lua(full_line)
                if(keybind != None):
                    current_content["keybinds"].append(keybind)
                reading_line += offset
            elif line.lstrip().startswith("--#/#"):
                match = re.search(r'--#/#\s*binde?\s*=\s*(.+?)\s*,,?\s*--\s*(.+)', line)
                if match:
                    comment = match.group(2).strip()
                    if "[hidden]" not in comment:
                        keys_str = match.group(1).replace(',', '+')
                        parts = keys_str.split('+')
                        mods = [m.strip() for m in parts[:-1] if m.strip()]
                        key = parts[-1].strip()
                        
                        mod_mapping = {
                            "ctrl": "Ctrl", "control": "Ctrl", "super": "Super",
                            "alt": "Alt", "mod1": "Alt", "shift": "Shift"
                        }
                        normalized_mods = [mod_mapping.get(m.lower(), m) for m in mods]
                        
                        current_content["keybinds"].append(KeyBinding(normalized_mods, key, "exec", "", comment))
        else:
            if line.startswith(COMMENT_BIND_PATTERN):
                keybind = get_keybind_at_line(reading_line, line_start=len(COMMENT_BIND_PATTERN))
                if(keybind != None):
                    current_content["keybinds"].append(keybind)

            elif line == "" or not line.lstrip().startswith("bind"): # Comment, ignore
                pass

            else: # Normal keybind
                keybind = get_keybind_at_line(reading_line)
                if(keybind != None):
                    current_content["keybinds"].append(keybind)

        reading_line += 1

    return current_content;

def parse_keys(path: str) -> Dict[str, List[KeyBinding]]:
    global content_lines
    content_lines = read_content(path).splitlines()
    if content_lines[0] == "error":
        return "error"
    is_lua = path.endswith(".lua")
    result = get_binds_recursive(Section([], [], ""), 0, is_lua)
    
    # Ensure nested column structure: Root -> Column (name="") -> Sections
    needs_wrapping = False
    for child in result["children"]:
        if len(child["keybinds"]) > 0 or len(child["children"]) == 0:
            needs_wrapping = True
            break
    if needs_wrapping and (len(result["children"]) > 0 or len(result["keybinds"]) > 0):
        column = Section(result["children"], result["keybinds"], "")
        result["children"] = [column]
        
    return result


if __name__ == "__main__":
    import json

    ParsedKeys = parse_keys(args.path)
    print(json.dumps(ParsedKeys))
