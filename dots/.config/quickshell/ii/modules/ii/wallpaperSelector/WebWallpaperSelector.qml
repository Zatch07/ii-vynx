import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root
    property bool _zatchLoadState: false
    Component.onCompleted: _zatchLoadState = GlobalStates.webWallpaperSelectorOpen

    Connections {
        target: GlobalStates
        function onWebWallpaperSelectorOpenChanged() {
            if (GlobalStates.webWallpaperSelectorOpen) {
                root._zatchLoadState = true;
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
            WlrLayershell.namespace: "quickshell:webWallpaperSelector"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            color: "transparent"

            anchors.top: true
            margins {
                top: Config?.options.bar.vertical ? Appearance.sizes.hyprlandGapsOut : Appearance.sizes.barHeight + Appearance.sizes.hyprlandGapsOut
            }

            mask: Region {
                item: content
            }

            implicitHeight: Appearance.sizes.wallpaperSelectorHeight
            implicitWidth: Appearance.sizes.wallpaperSelectorWidth

            Component.onCompleted: {
                GlobalFocusGrab.addDismissable(panelWindow);
            }
            Component.onDestruction: {
                GlobalFocusGrab.removeDismissable(panelWindow);
            }
            Connections {
                target: GlobalFocusGrab
                function onDismissed() {
                    GlobalStates.webWallpaperSelectorOpen = false;
                }
            }

            WebWallpaperSelectorContent {
                id: content
                anchors {
                    fill: parent
                }
                onDismissFinished: {
                    root._zatchLoadState = false;
                }
            }
        }
    }

    function toggleWebWallpaperSelector() {
        if (Config.options.wallpaperSelector.useSystemFileDialog) {
            Wallpapers.openFallbackPicker(Appearance.m3colors.darkmode);
            return;
        }
        GlobalStates.webWallpaperSelectorOpen = !GlobalStates.webWallpaperSelectorOpen
    }

    IpcHandler {
        target: "webWallpaperSelector"

        function toggle(): void {
            root.toggleWebWallpaperSelector();
        }
    }

    GlobalShortcut {
        name: "webWallpaperSelectorToggle"
        description: "Toggle web wallpaper selector"
        onPressed: {
            root.toggleWebWallpaperSelector();
        }
    }
}
