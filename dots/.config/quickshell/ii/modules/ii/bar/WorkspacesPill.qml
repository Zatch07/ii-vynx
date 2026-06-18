import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property bool vertical: false
    property bool borderless: Config.options.bar.borderless
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property int effectiveActiveWorkspaceId: monitor?.activeWorkspace?.id ?? 1
    
    readonly property int workspacesShown: Config.options.bar.workspaces.shown
    readonly property int workspaceGroup: Math.floor((effectiveActiveWorkspaceId - 1) / root.workspacesShown)
    property list<bool> workspaceOccupied: []
    property int widgetPadding: 4
    property int workspaceButtonWidth: 26
    property real workspaceIconSize: workspaceButtonWidth * 0.69
    
    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({ length: root.workspacesShown }, (_, i) => {
            return Hyprland.workspaces.values.some(ws => ws.id === workspaceGroup * root.workspacesShown + i + 1);
        })
    }

    Component.onCompleted: updateWorkspaceOccupied()
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() { updateWorkspaceOccupied(); }
    }
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() { updateWorkspaceOccupied(); }
    }
    onWorkspaceGroupChanged: updateWorkspaceOccupied()

    implicitWidth: root.vertical ? Appearance.sizes.verticalBarWidth : layout.implicitWidth
    implicitHeight: root.vertical ? layout.implicitHeight : Appearance.sizes.barHeight

    // Scroll to switch workspaces
    WheelHandler {
        onWheel: (event) => {
            if (event.angleDelta.y < 0)
                Hyprland.dispatch(`hl.dsp.focus({workspace = "r+1"})`);
            else if (event.angleDelta.y > 0)
                Hyprland.dispatch(`hl.dsp.focus({workspace = "r-1"})`);
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    property int hoverIndex: -1

    Rectangle {
        id: hoverIndicator
        z: 2
        property var hoveredItem: root.hoverIndex !== -1 ? repeater.itemAt(root.hoverIndex) : null
        property var hoveredVisual: hoveredItem ? hoveredItem.visualRect : null
        
        visible: root.hoverIndex !== -1
        opacity: visible ? 0.1 : 0
        
        width: hoveredVisual ? hoveredVisual.width : width
        height: hoveredVisual ? hoveredVisual.height : height
        x: (hoveredItem && hoveredVisual) ? layout.x + hoveredItem.x + hoveredVisual.x : x
        y: (hoveredItem && hoveredVisual) ? layout.y + hoveredItem.y + hoveredVisual.y : y
        
        radius: Appearance.rounding.full
        color: Appearance.colors.colPrimary
        
        property bool wasVisible: false
        onVisibleChanged: {
            if (visible && !wasVisible) {
                xBehavior.enabled = false;
                yBehavior.enabled = false;
                wBehavior.enabled = false;
                hBehavior.enabled = false;
                Qt.callLater(function() {
                    xBehavior.enabled = true;
                    yBehavior.enabled = true;
                    wBehavior.enabled = true;
                    hBehavior.enabled = true;
                });
            }
            wasVisible = visible;
        }

        Behavior on x { id: xBehavior; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on y { id: yBehavior; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on width { id: wBehavior; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on height { id: hBehavior; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on opacity { animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(hoverIndicator) }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        onPressed: (event) => {
            if (event.button === Qt.BackButton) {
                Hyprland.dispatch(`hl.dsp.workspace.toggle_special("special")`);
            } 
        }
    }

    GridLayout {
        id: layout
        anchors.centerIn: parent
        columns: root.vertical ? 1 : root.workspacesShown
        rows: root.vertical ? root.workspacesShown : 1
        columnSpacing: 0
        rowSpacing: 0

        Repeater {
            id: repeater
            model: root.workspacesShown

            Button {
                id: button
                property int workspaceValue: workspaceGroup * root.workspacesShown + index + 1
                property bool isActive: root.effectiveActiveWorkspaceId === workspaceValue
                property bool isOccupied: workspaceOccupied[index]
                property bool isVisible: !Config.options.bar.workspaces.dynamicWorkspaces || isActive || isOccupied
                visible: isVisible
                
                property alias visualRect: bgRect
                
                // Get windows for this workspace. Exclude floating if desired, but here we just show all.
                property var workspaceWindows: HyprlandData.windowList.filter(w => w.workspace.id === workspaceValue)
                property int maxIcons: Config.options.bar.workspaces.maxWindowCount
                
                onPressed: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspaceValue} })`)

                HoverHandler {
                    onHoveredChanged: {
                        if (hovered) root.hoverIndex = index;
                        else if (root.hoverIndex === index) root.hoverIndex = -1;
                    }
                }

                // Base size + expanded size
                property int activeExtraPixels: workspaceWindows.length > 0 ? (Math.min(workspaceWindows.length, maxIcons) * 22 + 8) : 12

                implicitWidth: root.vertical ? Appearance.sizes.verticalBarWidth : (isActive ? workspaceButtonWidth + activeExtraPixels : workspaceButtonWidth) + 4
                implicitHeight: root.vertical ? (isActive ? workspaceButtonWidth + activeExtraPixels : workspaceButtonWidth) + 4 : Appearance.sizes.barHeight
                
                Behavior on implicitWidth { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
                Behavior on implicitHeight { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }

                background: Item {
                    Rectangle {
                        id: bgRect
                        anchors.centerIn: parent
                        width: root.vertical ? workspaceButtonWidth : (isActive ? workspaceButtonWidth + activeExtraPixels : workspaceButtonWidth)
                        height: root.vertical ? (isActive ? workspaceButtonWidth + activeExtraPixels : workspaceButtonWidth) : workspaceButtonWidth

                        radius: Appearance.rounding.full
                        color: button.isActive ? Appearance.colors.colPrimary : 
                               (button.isOccupied ? ColorUtils.transparentize(Appearance.m3colors.m3secondaryContainer, 0.4) : "transparent")
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
                        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }

                        Item {
                            anchors.fill: parent
                            clip: true // Prevents overflowing while animating

                        // Layout for icons
                        GridLayout {
                            anchors.centerIn: parent
                            columns: root.vertical ? 1 : button.maxIcons + 1
                            rows: root.vertical ? button.maxIcons + 1 : 1
                            columnSpacing: 4
                            rowSpacing: 4

                            // When active, show app icons
                            Repeater {
                                model: button.isActive ? Math.min(button.workspaceWindows.length, button.maxIcons) : 0
                                
                                Item {
                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18
                                    
                                    Image {
                                        id: iconImg
                                        anchors.fill: parent
                                        property var win: button.workspaceWindows[index]
                                        source: win ? Quickshell.iconPath(AppSearch.guessIcon(win.class), "image-missing") : ""
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        
                                        opacity: 0
                                        Component.onCompleted: opacity = 1
                                        Behavior on opacity { NumberAnimation { duration: 200 } }
                                    }
                                    
                                    Loader {
                                        active: Config.options.bar.workspaces.monochromeIcons
                                        anchors.fill: iconImg
                                        sourceComponent: Item {
                                            Desaturate {
                                                id: desaturatedIcon
                                                visible: false
                                                anchors.fill: parent
                                                source: iconImg
                                                desaturation: 0.8
                                            }
                                            ColorOverlay {
                                                anchors.fill: desaturatedIcon
                                                source: desaturatedIcon
                                                color: ColorUtils.transparentize(Appearance.colors.colOnLayer1, 0.9)
                                            }
                                        }
                                    }
                                }
                            }

                            // If active but NO apps, or if inactive, show the dot/text
                            Item {
                                visible: !button.isActive || button.workspaceWindows.length === 0
                                Layout.preferredWidth: 18
                                Layout.preferredHeight: 18
                                Layout.alignment: Qt.AlignCenter

                                property var numberMap: Config.options.bar.workspaces.numberMap
                                property bool isPacmanStyle: numberMap && numberMap.length > 0 && numberMap[0] === "pacman"

                                StyledText {
                                    anchors.centerIn: parent
                                    visible: parent.isPacmanStyle
                                    font {
                                        pixelSize: button.isOccupied ? (Appearance.font.pixelSize.title * 0.8) : (Appearance.font.pixelSize.small * 0.6)
                                        family: Appearance.font.family.iconNerd
                                    }
                                    text: button.isActive ? "󰮯" : (button.isOccupied ? "󰊠" : "")
                                    color: button.isActive ? Appearance.colors.colOnPrimary : 
                                          (button.isOccupied ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer1Inactive)

                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                StyledText {
                                    anchors.centerIn: parent
                                    visible: !parent.isPacmanStyle
                                    font {
                                        pixelSize: Appearance.font.pixelSize.small * 0.8
                                        bold: true
                                    }
                                    property var displayVal: parent.numberMap && parent.numberMap[button.workspaceValue - 1] ? parent.numberMap[button.workspaceValue - 1] : button.workspaceValue
                                    text: parent.isPacmanStyle ? "" : (displayVal === "dots" ? button.workspaceValue : displayVal)
                                    color: button.isActive ? Appearance.colors.colOnPrimary : 
                                          (button.isOccupied ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer1Inactive)

                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
}
