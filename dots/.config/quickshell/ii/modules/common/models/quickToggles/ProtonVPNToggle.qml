import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import Quickshell
import Quickshell.Io

QuickToggleModel {
    id: root
    name: Translation.tr("Proton VPN")

    toggled: false
    available: true
    icon: "shield_lock"

    // Track previous state to detect changes and fire notifications
    property bool _prevToggled: false
    property bool _initialCheck: true

    mainAction: () => {
        // Run the toggle, then let the status timer reconcile true state
        // Do NOT optimistically flip — wait for real status check
        Quickshell.execDetached(["bash", "-c", "/home/zatch/.config/hypr/custom/scripts/vpn-manager.sh toggle"])
        // Shorten next poll so it feels responsive
        statusCheckTimer.interval = 500
    }

    function checkStatus() {
        var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
        proc.command = ["bash", "-c", "/home/zatch/.config/hypr/custom/scripts/vpn-manager.sh status"]
        var collector = Qt.createQmlObject('import Quickshell.Io; StdioCollector {}', proc)
        proc.stdout = collector

        collector.onStreamFinished.connect(function() {
            var output = collector.text.trim()
            var newToggled = false
            var newAvailable = true

            if (output.startsWith("ON:")) {
                newToggled = true
                var connName = output.split(":")[1]
                root.tooltipText = Translation.tr("Proton VPN (Connected: " + connName + ")")
            } else if (output.startsWith("OFF:")) {
                newToggled = false
                root.tooltipText = Translation.tr("Proton VPN (Ready)")
            } else {
                newToggled = false
                newAvailable = false
                root.tooltipText = Translation.tr("Proton VPN (No Configs Found)")
            }

            // Fire a notification only when state actually changes (not on first load)
            if (!root._initialCheck && newToggled !== root._prevToggled) {
                if (newToggled) {
                    Quickshell.execDetached(["notify-send", "Proton VPN", "🔒 VPN Connected", "-a", "Shell", "-i", "network-vpn"])
                } else {
                    Quickshell.execDetached(["notify-send", "Proton VPN", "🔓 VPN Disconnected", "-a", "Shell", "-i", "network-vpn-disconnected"])
                }
            }

            root._prevToggled = newToggled
            root.toggled = newToggled
            root.available = newAvailable
            root._initialCheck = false

            // Reset timer to normal interval after action
            statusCheckTimer.interval = 3000
            proc.destroy()
        })
        proc.running = true
    }

    // Poll every 3s to keep state in sync
    Timer {
        id: statusCheckTimer
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.checkStatus()
    }
}
