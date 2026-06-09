pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

import qs.modules.common
import qs.modules.common.functions

/**
 * Configs Hyprland
 */
Singleton {
    id: root
    
    signal reloaded()

    readonly property string configuratorScriptPath: Quickshell.shellPath("scripts/hyprland/hyprconfigurator.py")
    readonly property string shellOverridesPath: FileUtils.trimFileProtocol(`${Directories.config}/hypr/hyprland/shellOverrides/main.conf`)

    function set(key: string, value: var) {
        Quickshell.execDetached(["bash", "-c", //
            `${Directories.cliPath} hyprset key '${key}' '${value}' >/dev/null 2>&1 || true; hyprctl reload` //
        ])
    }
    
    function setMany(entries: var) {
        let cmds = ""
        for (let key in entries) {
            cmds += `${Directories.cliPath} hyprset key '${key}' '${entries[key]}' >/dev/null 2>&1; `
        }
        cmds += "hyprctl reload;"
        Quickshell.execDetached(["bash", "-c", cmds])
    }
    
    function reset(key: string) {
        Quickshell.execDetached(["bash", "-c", //
            `${Directories.cliPath} hyprset reset '${key}' >/dev/null 2>&1 || true; hyprctl reload` //
        ])
    }
    
    function resetMany(keys: list<string>) {
        let cmds = ""
        for (let i = 0; i < keys.length; i++) {
            cmds += `${Directories.cliPath} hyprset reset '${keys[i]}' >/dev/null 2>&1; `
        }
        cmds += "hyprctl reload;"
        Quickshell.execDetached(["bash", "-c", cmds])
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name == "configreloaded") {
                root.reloaded()
            }
        }
    }
}
