//@ pragma Env QS_CRASHREPORT_URL=https://github.com/caelestia-dots/shell/issues/new?template=crash.yml
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QS_DROP_EXPENSIVE_FONTS=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Effects
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.modules.dashboard as Dashboard
import qs.services

ShellRoot {
    settings.watchFiles: true

    Variants {
        model: Screens.screens

        Scope {
            id: scope
            required property ShellScreen modelData

            StyledWindow {
                id: root

                readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
                screen: scope.modelData
                name: "dashboard-overlay"

                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                anchors.right: true

                mask: visibilities.dashboard ? screenRegion : emptyRegion

                Region {
                    id: screenRegion
                    x: 0
                    y: 0
                    width: root.width
                    height: root.height
                }

                Region {
                    id: emptyRegion
                }

                IpcHandler {
                    target: "hoverboard"
                    function toggle(): void {
                        visibilities.dashboard = !visibilities.dashboard;
                    }
                    function open(): void {
                        visibilities.dashboard = true;
                    }
                    function close(): void {
                        visibilities.dashboard = false;
                    }
                }

                QtObject {
                    id: visibilities
                    property bool dashboard: true
                }

                CustomMouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.AllButtons

                    function withinPanelWidth(panel: Item, x: real, y: real): bool {
                        const panelX = panel.x;
                        return x >= panelX - Config.border.rounding && x <= panelX + panel.width + Config.border.rounding;
                    }

                    function inTopPanel(panel: Item, x: real, y: real): bool {
                        return y >= panel.y && y <= (panel.y + panel.height) && withinPanelWidth(panel, x, y);
                    }

                    onPressed: event => {
                        if (visibilities.dashboard && !inTopPanel(dashboard, event.x, event.y)) {
                            visibilities.dashboard = false;
                        }
                    }
                }

                Dashboard.Wrapper {
                    id: dashboard

                    visibilities: visibilities

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                }
            }
        }
    }
}
