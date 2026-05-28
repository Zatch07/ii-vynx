import "../../../quickshell/ii"
import "../../../quickshell/ii/services"
import "../../../quickshell/ii/modules/common"
import "../../../quickshell/ii/modules/common/widgets"
import "../../../quickshell/ii/modules/common/functions"
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: root

    property bool open: false

    property bool _zatchLoadState: false

    onOpenChanged: {
        if (open) {
            _zatchLoadState = true
        } else {
            // Tell the content to play the out-animation!
            if (wallpaperSelectorLoader.item && wallpaperSelectorLoader.item.contentItem) {
                wallpaperSelectorLoader.item.contentItem.requestClose()
            }
        }
    }

    Loader {
        id: wallpaperSelectorLoader
        active: root._zatchLoadState

        sourceComponent: PanelWindow {
            id: panelWindow
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(panelWindow.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell:wallpaperSelector"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            color: "transparent"

            // Anchor left/right/top only — fixed height keeps the window bounded.
            // Do NOT anchor bottom=true; that caused the full-screen overlay crash.
            anchors.top: true
            anchors.left: true
            anchors.right: true
            margins {
                // Push down from bar so it sits in the vertical centre of the screen
                top: Math.max(0, (monitor.height / 2) - 310)
            }

            // Only the content rectangle intercepts input
            mask: Region {
                item: content
            }

            implicitHeight: 620
            implicitWidth: monitor.width

            Component.onCompleted: {
                // GlobalFocusGrab.addDismissable(panelWindow)
            }
            Component.onDestruction: {
                // GlobalFocusGrab.removeDismissable(panelWindow)
            }
            // Connections {
            //     target: GlobalFocusGrab
            //     function onDismissed() {
            //         root.open = false
            //     }
            // }

            WallpaperSelectorContent {
                id: content
                objectName: "content" // to find it easily if needed
                anchors.fill: parent
                onCloseRequested: root.open = false
                onDismissFinished: root._zatchLoadState = false
            }
            // Expose the content so the shell can call it!
            property var contentItem: content
        }
    }

    function toggleWallpaperSelector() {
        root.open = !root.open
    }

    IpcHandler {
        target: "customWallpaperSelector"
        function toggle(): void { root.toggleWallpaperSelector() }
        function random(): void { Wallpapers.randomFromCurrentFolder() }
    }

    GlobalShortcut {
        name: "customWallpaperSelectorToggle"
        description: "Toggle custom wallpaper selector"
        onPressed: root.toggleWallpaperSelector()
    }

    GlobalShortcut {
        name: "customWallpaperSelectorRandom"
        description: "Select random wallpaper in current folder"
        onPressed: Wallpapers.randomFromCurrentFolder()
    }
}
