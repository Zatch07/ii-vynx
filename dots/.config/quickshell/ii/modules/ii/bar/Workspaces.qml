import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
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
    property real activeWorkspaceMargin: 2
    property real workspaceIconSize: workspaceButtonWidth * 0.69
    property real workspaceIconSizeShrinked: workspaceButtonWidth * 0.55
    property real workspaceIconOpacityShrinked: 1
    property real workspaceIconMarginShrinked: -4
    property int workspaceIndexInGroup: (effectiveActiveWorkspaceId - 1) % root.workspacesShown

    // --- PACMAN ANIMATION TRACKING ---
    property int previousWorkspaceId: effectiveActiveWorkspaceId
    property bool isMovingLeft: false

    onEffectiveActiveWorkspaceIdChanged: {
        isMovingLeft = effectiveActiveWorkspaceId < previousWorkspaceId;
        previousWorkspaceId = effectiveActiveWorkspaceId;
    }
    // ---------------------------------

    // Function to update workspaceOccupied
    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({ length: root.workspacesShown }, (_, i) => {
            return Hyprland.workspaces.values.some(ws => ws.id === workspaceGroup * root.workspacesShown + i + 1);
        })
    }

    // Occupied workspace updates
    Component.onCompleted: updateWorkspaceOccupied()
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            updateWorkspaceOccupied();
        }
    }
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            updateWorkspaceOccupied();
        }
    }
    onWorkspaceGroupChanged: {
        updateWorkspaceOccupied();
    }

    implicitWidth: root.vertical ? Appearance.sizes.verticalBarWidth : (root.workspaceButtonWidth * root.workspacesShown)
    implicitHeight: root.vertical ? (root.workspaceButtonWidth * root.workspacesShown) : Appearance.sizes.barHeight

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

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        onPressed: (event) => {
            if (event.button === Qt.BackButton) {
                Hyprland.dispatch(`hl.dsp.workspace.toggle_special("special")`);
            } 
        }
    }

    // Workspaces - background
    Grid {
        z: 1
        anchors.centerIn: parent

        rowSpacing: 0
        columnSpacing: 0
        columns: root.vertical ? 1 : root.workspacesShown
        rows: root.vertical ? root.workspacesShown : 1

        Repeater {
            model: root.workspacesShown

            Rectangle {
                z: 1
                implicitWidth: workspaceButtonWidth
                implicitHeight: workspaceButtonWidth
                radius: (width / 2)
                property var previousOccupied: (workspaceOccupied[index-1] && !(!activeWindow?.activated && root.effectiveActiveWorkspaceId === index))
                property var rightOccupied: (workspaceOccupied[index+1] && !(!activeWindow?.activated && root.effectiveActiveWorkspaceId === index+2))
                property var radiusPrev: previousOccupied ? 0 : (width / 2)
                property var radiusNext: rightOccupied ? 0 : (width / 2)

                topLeftRadius: radiusPrev
                bottomLeftRadius: root.vertical ? radiusNext : radiusPrev
                topRightRadius: root.vertical ? radiusPrev : radiusNext
                bottomRightRadius: radiusNext
                
                color: ColorUtils.transparentize(Appearance.m3colors.m3secondaryContainer, 0.4)
                opacity: 0 // Pacman style: no background pills

                Behavior on opacity {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
                Behavior on radiusPrev {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }

                Behavior on radiusNext {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }

            }

        }

    }

    // Active workspace
    Rectangle {
        visible: false // Pacman style: no sliding active indicator
        z: 2
        // Make active ws indicator, which has a brighter color, smaller to look like it is of the same size as ws occupied highlight
        radius: Appearance.rounding.full
        color: Appearance.colors.colPrimary

        anchors {
            verticalCenter: vertical ? undefined : parent.verticalCenter
            horizontalCenter: vertical ? parent.horizontalCenter : undefined
        }

        AnimatedTabIndexPair {
            id: idxPair
            index: root.workspaceIndexInGroup
        }
        property real indicatorPosition: Math.min(idxPair.idx1, idxPair.idx2) * workspaceButtonWidth + root.activeWorkspaceMargin
        property real indicatorLength: Math.abs(idxPair.idx1 - idxPair.idx2) * workspaceButtonWidth + workspaceButtonWidth - root.activeWorkspaceMargin * 2
        property real indicatorThickness: workspaceButtonWidth - root.activeWorkspaceMargin * 2

        x: root.vertical ? null : indicatorPosition
        implicitWidth: root.vertical ? indicatorThickness : indicatorLength
        y: root.vertical ? indicatorPosition : null
        implicitHeight: root.vertical ? indicatorLength : indicatorThickness

    }

    // Workspaces - numbers
    Grid {
        z: 3

        columns: root.vertical ? 1 : root.workspacesShown
        rows: root.vertical ? root.workspacesShown : 1
        columnSpacing: 0
        rowSpacing: 0

        anchors.fill: parent

        Repeater {
            model: root.workspacesShown

            Button {
                id: button
                property int workspaceValue: workspaceGroup * root.workspacesShown + index + 1
                implicitHeight: vertical ? Appearance.sizes.verticalBarWidth : Appearance.sizes.barHeight
                implicitWidth: vertical ? Appearance.sizes.verticalBarWidth : Appearance.sizes.verticalBarWidth
                onPressed: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspaceValue} })`)
                width: vertical ? undefined : workspaceButtonWidth
                height: vertical ? workspaceButtonWidth : undefined

                background: Item {
                    id: workspaceButtonBackground
                    implicitWidth: workspaceButtonWidth
                    implicitHeight: workspaceButtonWidth
                    property var biggestWindow: HyprlandData.biggestWindowForWorkspace(button.workspaceValue)
                    property var mainAppIconSource: Quickshell.iconPath(AppSearch.guessIcon(biggestWindow?.class), "image-missing")

                    StyledText { // Static Grid: Ghosts and Dots
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        
                        // Hide the dot/ghost underneath if this is the active workspace
                        opacity: (root.effectiveActiveWorkspaceId == button.workspaceValue) ? 0 : 1
                        
                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }

                        font {
                            pixelSize: workspaceOccupied[index] ? (Appearance.font.pixelSize.title * 0.8) : (Appearance.font.pixelSize.small * 0.6)
                            family: Appearance.font.family.iconNerd
                        }
                        
                        text: workspaceOccupied[index] ? "󰊠" : ""
                            
                        color: workspaceOccupied[index] ? 
                            Appearance.m3colors.m3onSecondaryContainer : 
                            Appearance.colors.colOnLayer1Inactive

                        Behavior on color {
                            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                    }
                }
                

            }

        }

    }

    // --- PACMAN OVERLAYS (Main + 2 Trails) ---

    // Trail 2 (Faintest, Slowest)
    Item {
        z: 4
        opacity: 0.2 // 20% visible
        width: workspaceButtonWidth
        height: root.vertical ? workspaceButtonWidth : Appearance.sizes.barHeight
        property real targetPos: root.workspaceIndexInGroup * workspaceButtonWidth
        x: root.vertical ? 0 : targetPos
        y: root.vertical ? targetPos : 0

        Behavior on x { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

        StyledText {
            id: pacmanTrail2
            anchors.centerIn: parent
            text: "󰮯"
            color: Appearance.colors.colPrimary
            font { pixelSize: Appearance.font.pixelSize.title; family: Appearance.font.family.iconNerd }
            transform: Scale {
                origin.x: pacmanTrail2.width / 2; origin.y: pacmanTrail2.height / 2
                xScale: root.isMovingLeft ? -1 : 1
            }
        }
    }

    // Trail 1 (Medium, Medium Speed)
    Item {
        z: 5
        opacity: 0.5 // 50% visible
        width: workspaceButtonWidth
        height: root.vertical ? workspaceButtonWidth : Appearance.sizes.barHeight
        property real targetPos: root.workspaceIndexInGroup * workspaceButtonWidth
        x: root.vertical ? 0 : targetPos
        y: root.vertical ? targetPos : 0

        Behavior on x { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

        StyledText {
            id: pacmanTrail1
            anchors.centerIn: parent
            text: "󰮯"
            color: Appearance.colors.colPrimary
            font { pixelSize: Appearance.font.pixelSize.title; family: Appearance.font.family.iconNerd }
            transform: Scale {
                origin.x: pacmanTrail1.width / 2; origin.y: pacmanTrail1.height / 2
                xScale: root.isMovingLeft ? -1 : 1
            }
        }
    }

    // Main Pacman (Solid, Fastest)
    Item {
        id: pacmanOverlay // ID required so the dots know where the mouth is!
        z: 6
        width: workspaceButtonWidth
        height: root.vertical ? workspaceButtonWidth : Appearance.sizes.barHeight
        property real targetPos: root.workspaceIndexInGroup * workspaceButtonWidth
        x: root.vertical ? 0 : targetPos
        y: root.vertical ? targetPos : 0

        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        StyledText {
            id: pacmanIcon 
            anchors.centerIn: parent
            text: "󰮯"
            color: Appearance.colors.colPrimary
            font { pixelSize: Appearance.font.pixelSize.title; family: Appearance.font.family.iconNerd }
            
            transform: Scale {
                origin.x: pacmanIcon.width / 2
                origin.y: pacmanIcon.height / 2
                xScale: root.isMovingLeft ? -1 : 1
                Behavior on xScale { NumberAnimation { duration: 150 } }
            }
        }
    }

}
