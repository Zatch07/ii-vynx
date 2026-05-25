//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ShellRoot {
    id: root

    // We use a PanelWindow for the pop-up behavior
    PanelWindow {
        id: panelWindow
        
        // Center the window on the focused monitor
        readonly property HyprlandMonitor monitor: Hyprland.focusedMonitor
        screen: monitor?.name ?? ""
        
        // Pop-up properties
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:customSettings"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        
        color: "transparent"

        // Size
        implicitWidth: 800
        implicitHeight: 600

        // Handle focus and dismissal
        Component.onCompleted: {
            MaterialThemeLoader.reapplyTheme()
            GlobalFocusGrab.addDismissable(panelWindow)
            entranceAnim.start()
        }
        Component.onDestruction: {
            GlobalFocusGrab.removeDismissable(panelWindow)
        }
        
        Connections {
            target: GlobalFocusGrab
            function onDismissed() {
                Qt.quit()
            }
        }

        // The actual content
        Rectangle {
            id: windowContent
            anchors.fill: parent
            color: Appearance.m3colors.m3surfaceContainerLow
            radius: Appearance.rounding.windowRounding
            border.color: Appearance.colors.colLayer3
            border.width: 1

            // Entrance state
            opacity: 0
            scale: 0.9

            // Header
            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 16
                }
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    
                    MaterialShapeWrappedMaterialSymbol {
                        iconSize: Appearance.font.pixelSize.huge
                        shape: MaterialShape.Shape.Ghostish
                        text: "settings_suggest"
                    }

                    StyledText {
                        text: "Custom Settings"
                        color: Appearance.colors.colOnLayer0
                        font {
                            family: Appearance.font.family.title
                            pixelSize: Appearance.font.pixelSize.title
                        }
                    }

                    Item { Layout.fillWidth: true }

                    RippleButton {
                        buttonRadius: Appearance.rounding.full
                        implicitWidth: 35
                        implicitHeight: 35
                        onClicked: Qt.quit()
                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            text: "close"
                            iconSize: 20
                        }
                    }
                }

                // Main Content
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Appearance.colors.colLayer1
                    radius: Appearance.rounding.large
                    clip: true

                    Loader {
                        id: pageLoader
                        anchors.fill: parent
                        anchors.margins: 8
                        source: "modules/custom/CursorSettings.qml"
                    }
                }
                
                // Footer / Search hint
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Press ESC or click close to exit"
                    color: Appearance.colors.colSubtext
                    font.pixelSize: Appearance.font.pixelSize.smallie
                }
            }
        }

        ParallelAnimation {
            id: entranceAnim
            NumberAnimation { target: windowContent; property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
            NumberAnimation { target: windowContent; property: "scale"; from: 0.9; to: 1; duration: 250; easing.type: Easing.OutBack }
        }
    }
}
