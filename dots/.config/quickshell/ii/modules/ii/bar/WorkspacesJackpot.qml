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
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property int effectiveActiveWorkspaceId: monitor?.activeWorkspace?.id ?? 1
    
    readonly property int workspacesShown: Config.options.bar.workspaces.shown
    readonly property int workspaceGroup: Math.floor((effectiveActiveWorkspaceId - 1) / root.workspacesShown)
    property list<bool> workspaceOccupied: []
    property int workspaceButtonWidth: 26
    
    property int hoverIndex: -1

    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({ length: root.workspacesShown }, (_, i) => {
            return Hyprland.workspaces.values.some(ws => ws.id === workspaceGroup * root.workspacesShown + i + 1);
        })
    }
    Component.onCompleted: updateWorkspaceOccupied()
    Connections { target: Hyprland.workspaces; function onValuesChanged() { updateWorkspaceOccupied(); } }
    Connections { target: Hyprland; function onFocusedWorkspaceChanged() { updateWorkspaceOccupied(); } }
    onWorkspaceGroupChanged: updateWorkspaceOccupied()

    implicitWidth: Math.max(normalLayout.implicitWidth, root.vertical ? Appearance.sizes.verticalBarWidth : 80)
    implicitHeight: Math.max(normalLayout.implicitHeight, root.vertical ? 80 : Appearance.sizes.barHeight)
    clip: true

    // Scroll to switch workspaces
    WheelHandler {
        onWheel: (event) => {
            if (event.angleDelta.y < 0) Hyprland.dispatch(`hl.dsp.focus({workspace = "r+1"})`);
            else if (event.angleDelta.y > 0) Hyprland.dispatch(`hl.dsp.focus({workspace = "r-1"})`);
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    Rectangle {
        id: hoverIndicator
        z: 2
        property var hoveredItem: root.hoverIndex !== -1 ? repeater.itemAt(root.hoverIndex) : null
        property var hoveredVisual: hoveredItem ? hoveredItem.visualRect : null
        
        visible: root.hoverIndex !== -1
        opacity: visible ? 0.1 : 0
        
        width: hoveredVisual ? hoveredVisual.width : width
        height: hoveredVisual ? hoveredVisual.height : height
        x: (hoveredItem && hoveredVisual) ? normalLayer.x + normalLayout.x + hoveredItem.x + hoveredVisual.x : x
        y: (hoveredItem && hoveredVisual) ? normalLayer.y + normalLayout.y + hoveredItem.y + hoveredVisual.y : y
        
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

    // Jackpot State Machine
    property bool isJackpotActive: false
    property bool isSpinning: false
    property bool showJackpotText: false

    property string slot1Icon: ""
    property string slot2Icon: ""
    property string slot3Icon: ""

    Timer {
        id: spinTimer
        interval: 100
        repeat: true
        property int spinCount: 0
        
        onTriggered: {
            spinCount++
            
            // Pick random icons from currently active windows on the monitor
            let winList = root.monitorWindows
            if (winList && winList.length > 0) {
                root.slot1Icon = winList[Math.floor(Math.random() * winList.length)].icon
                root.slot2Icon = winList[Math.floor(Math.random() * winList.length)].icon
                root.slot3Icon = winList[Math.floor(Math.random() * winList.length)].icon
            } else {
                root.slot1Icon = "image-missing"
                root.slot2Icon = "image-missing"
                root.slot3Icon = "image-missing"
            }

            if (spinCount >= 10) {
                stop()
                root.isSpinning = false
                
                // Determine if jackpot
                let winCount = root.activeWindowsCount
                if (winCount > 0) {
                    // Force a win condition sometimes if there are windows
                    if (Math.random() > 0.3) {
                        let win = winList[0] // just pick the first for a guaranteed match
                        root.slot1Icon = win.icon
                        root.slot2Icon = win.icon
                        root.slot3Icon = win.icon
                        root.showJackpotText = true
                    }
                }
                
                resetTimer.start()
            }
        }
    }

    Timer {
        id: resetTimer
        interval: root.showJackpotText ? 2000 : 800
        onTriggered: {
            root.showJackpotText = false
            root.isJackpotActive = false
        }
    }

    // Capture Super Key Down
    Connections {
        target: GlobalStates
        function onSuperDownChanged() {
            if (GlobalStates.superDown && !root.isJackpotActive && root.activeWindowsCount > 0) {
                root.isJackpotActive = true
                root.isSpinning = true
                root.showJackpotText = false
                spinTimer.spinCount = 0
                spinTimer.start()
            } else if (!GlobalStates.superDown && !root.showJackpotText) {
                // If super is released before jackpot animation finishes, optionally reset immediately or let it finish.
                // We'll let it finish.
            }
        }
    }

    // LAYER 1: Normal Workspaces (Pill Style)
    Item {
        id: normalLayer
        width: parent.width
        height: parent.height
        
        y: root.isJackpotActive ? (root.vertical ? 0 : -height) : 0
        x: root.isJackpotActive ? (root.vertical ? -width : 0) : 0
        
        Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
        Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }

        GridLayout {
            id: normalLayout
            anchors.centerIn: parent
            columns: root.vertical ? 1 : root.workspacesShown
            rows: root.vertical ? root.workspacesShown : 1
            columnSpacing: 0
            rowSpacing: 0

            Repeater {
                id: repeater
                model: root.workspacesShown

                Button {
                    id: normalButton
                    property int workspaceValue: workspaceGroup * root.workspacesShown + index + 1
                    property bool isActive: root.effectiveActiveWorkspaceId === workspaceValue
                    property bool isOccupied: workspaceOccupied[index]
                    property bool isVisible: !Config.options.bar.workspaces.dynamicWorkspaces || isActive || isOccupied
                    visible: isVisible

                    property alias visualRect: bgRect

                    property var workspaceWindows: HyprlandData.windowList.filter(w => w.workspace.id === workspaceValue)
                    property int maxIcons: Config.options.bar.workspaces.maxWindowCount

                    onPressed: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspaceValue} })`)

                    HoverHandler {
                        onHoveredChanged: {
                            if (hovered) root.hoverIndex = index;
                            else if (root.hoverIndex === index) root.hoverIndex = -1;
                        }
                    }

                    property int activeExtraPixels: workspaceWindows.length > 0 ? (Math.min(workspaceWindows.length, maxIcons) * 22 + 8) : 12

                    implicitWidth: root.vertical ? Appearance.sizes.verticalBarWidth : (isActive ? workspaceButtonWidth + activeExtraPixels : workspaceButtonWidth) + 4
                    implicitHeight: root.vertical ? (isActive ? workspaceButtonWidth + activeExtraPixels : workspaceButtonWidth) + 4 : Appearance.sizes.barHeight
                    
                    Behavior on implicitWidth { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
                    Behavior on implicitHeight { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }

                    background: Item {
                        Rectangle {
                            id: bgRect
                            anchors.centerIn: parent
                            width: root.vertical ? workspaceButtonWidth : (normalButton.isActive ? workspaceButtonWidth + activeExtraPixels : workspaceButtonWidth)
                            height: root.vertical ? (normalButton.isActive ? workspaceButtonWidth + activeExtraPixels : workspaceButtonWidth) : workspaceButtonWidth

                            radius: Appearance.rounding.full
                            color: normalButton.isActive ? Appearance.colors.colPrimary : 
                                   (normalButton.isOccupied ? ColorUtils.transparentize(Appearance.m3colors.m3secondaryContainer, 0.4) : "transparent")
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
                            Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }

                            Item {
                                anchors.fill: parent
                                clip: true

                            GridLayout {
                                anchors.centerIn: parent
                                columns: root.vertical ? 1 : normalButton.maxIcons + 1
                                rows: root.vertical ? normalButton.maxIcons + 1 : 1
                                columnSpacing: 4
                                rowSpacing: 4

                                // App icons
                                Repeater {
                                    model: normalButton.isActive ? Math.min(normalButton.workspaceWindows.length, normalButton.maxIcons) : 0
                                    
                                    Item {
                                        Layout.preferredWidth: 18
                                        Layout.preferredHeight: 18
                                        
                                        Image {
                                            id: iconImg
                                            anchors.fill: parent
                                            property var win: normalButton.workspaceWindows[index]
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

                                // Indicator text/dot
                                Item {
                                    visible: !normalButton.isActive || normalButton.workspaceWindows.length === 0
                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18
                                    Layout.alignment: Qt.AlignCenter

                                    property var numberMap: Config.options.bar.workspaces.numberMap
                                    // Treat "dots" as default if empty, unless it's explicitly numbers (user can select Normal/Roman etc)
                                    property bool isDotsStyle: numberMap && numberMap.length > 0 && numberMap[0] === "dots"
                                    property bool isPacmanStyle: numberMap && numberMap.length > 0 && numberMap[0] === "pacman"
                                    property bool isTextStyle: !isDotsStyle && !isPacmanStyle

                                    StyledText {
                                        anchors.centerIn: parent
                                        visible: !parent.isTextStyle
                                        font {
                                            pixelSize: normalButton.isOccupied ? (Appearance.font.pixelSize.title * 0.8) : (Appearance.font.pixelSize.small * 0.6)
                                            family: Appearance.font.family.iconNerd
                                        }
                                        text: {
                                            if (normalButton.isActive) return parent.isPacmanStyle ? "󰮯" : "";
                                            if (parent.isPacmanStyle) return normalButton.isOccupied ? "󰊠" : "";
                                            return ""; // Dots style
                                        }
                                        color: normalButton.isActive ? Appearance.colors.colOnPrimary : 
                                              (normalButton.isOccupied ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer1Inactive)

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    StyledText {
                                        anchors.centerIn: parent
                                        visible: parent.isTextStyle
                                        font {
                                            pixelSize: Appearance.font.pixelSize.small * 0.8
                                            bold: true
                                        }
                                        text: parent.isTextStyle ? (parent.numberMap && parent.numberMap[normalButton.workspaceValue - 1] ? parent.numberMap[normalButton.workspaceValue - 1] : normalButton.workspaceValue) : ""
                                        color: normalButton.isActive ? Appearance.colors.colOnPrimary : 
                                              (normalButton.isOccupied ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer1Inactive)

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

    // LAYER 2: Jackpot / Slot Machine
    Item {
        id: jackpotLayer
        width: parent.width
        height: parent.height
        
        y: root.isJackpotActive ? 0 : (root.vertical ? 0 : height)
        x: root.isJackpotActive ? 0 : (root.vertical ? width : 0)

        Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
        Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }

        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.full
            color: Appearance.colors.colLayer2
            border.color: Appearance.colors.colLayer3
            border.width: 1

            // Slots
            RowLayout {
                anchors.centerIn: parent
                spacing: 8
                opacity: root.showJackpotText ? 0.3 : 1.0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Image {
                    Layout.preferredWidth: 16; Layout.preferredHeight: 16
                    source: root.slot1Icon ? Quickshell.iconPath(root.slot1Icon, "image-missing") : ""
                }
                Image {
                    Layout.preferredWidth: 16; Layout.preferredHeight: 16
                    source: root.slot2Icon ? Quickshell.iconPath(root.slot2Icon, "image-missing") : ""
                }
                Image {
                    Layout.preferredWidth: 16; Layout.preferredHeight: 16
                    source: root.slot3Icon ? Quickshell.iconPath(root.slot3Icon, "image-missing") : ""
                }
            }

            // Jackpot Text
            StyledText {
                anchors.centerIn: parent
                text: "JACKPOT!"
                font.pixelSize: Appearance.font.pixelSize.small
                font.bold: true
                color: Appearance.colors.colPrimary
                visible: root.showJackpotText
                
                // Add a little pop animation
                scale: root.showJackpotText ? 1.2 : 0.5
                Behavior on scale { SpringAnimation { spring: 3; damping: 0.2 } }
            }
        }
    }
}
