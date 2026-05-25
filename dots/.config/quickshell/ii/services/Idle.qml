pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool inhibit: false

    readonly property string _sessionId: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || ""

    Timer {
        id: restoreTimer
        interval: 0
        repeat: false
        onTriggered: {
            if (!Persistent.ready) return
            const storedId = Persistent.states.idle.sessionId || ""
            if (storedId === root._sessionId) {
                root.inhibit = Persistent.states.idle.inhibit ?? false
            } else {
                root.inhibit = false
            }
        }
    }

    Connections {
        target: Persistent
        function onReadyChanged() { restoreTimer.restart() }
    }

    function toggleInhibit(active = null) {
        root.inhibit = active !== null ? active : !root.inhibit
        Persistent.states.idle.inhibit = root.inhibit
        Persistent.states.idle.sessionId = root._sessionId
    }

    Process {
        id: inhibitProcess
        running: root.inhibit
        command: [
            "systemd-inhibit", 
            "--what=idle", 
            "--who=quickshell", 
            "--why=Keep system awake", 
            "--mode=block", 
            "sleep", 
            "infinity"
        ]
    }
}
