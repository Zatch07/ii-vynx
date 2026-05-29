import qs
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Io
import Quickshell.Wayland
import qs.services

Item {
    id: root
    property bool vertical: false
    implicitWidth: gridLayout.implicitWidth + gridLayout.rowSpacing * 2
    implicitHeight: gridLayout.implicitHeight + gridLayout.columnSpacing * 2
    
    Behavior on implicitWidth {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
    Behavior on implicitHeight {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    property var clipHistory: []
    property bool clipboardPopupOpen: false

    Process {
        id: getHistoryProc
        command: ["bash", "-c", "cliphist list | head -n 5"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    let lines = text.trim().split("\n");
                    let items = [];
                    let imgCount = 1;
                    for (let i = 0; i < lines.length; i++) {
                        let parts = lines[i].split("\t");
                        if (parts.length > 1) {
                            let textContent = parts[1];
                            if (textContent.startsWith("[[ binary data")) {
                                textContent = "Image " + imgCount;
                                imgCount++;
                            }
                            items.push({ id: parts[0], text: textContent });
                        }
                    }
                    root.clipHistory = items;
                }
            }
        }
    }

    function fetchHistory() {
        getHistoryProc.running = false;
        getHistoryProc.running = true;
    }

    function pasteItem(id) {
        let cmd = `echo -n '${id}' | cliphist decode | wl-copy`;
        Quickshell.execDetached(["bash", "-c", cmd]);
        root.clipboardPopupOpen = false;
    }

    GridLayout {
        id: gridLayout
        columns: root.vertical ? 1 : -1
        rows: root.vertical ? -1 : 1

        rowSpacing: 4
        columnSpacing: 4
        anchors.centerIn: parent

        Loader {
            active: Config.options.bar.utilButtons.showScreenSnip
            visible: Config.options.bar.utilButtons.showScreenSnip
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: Quickshell.execDetached(["qs", "-p", Quickshell.shellPath(""), "ipc", "call", "region", "screenshot"]);
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 1
                    text: "screenshot_region"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showScreenRecord
            visible: Config.options.bar.utilButtons.showScreenRecord
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: Quickshell.execDetached([Directories.recordScriptPath])
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 1
                    text: "videocam"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showColorPicker
            visible: Config.options.bar.utilButtons.showColorPicker
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: Quickshell.execDetached(["hyprpicker", "-a"])
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 1
                    text: "colorize"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showKeyboardToggle
            visible: Config.options.bar.utilButtons.showKeyboardToggle
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: GlobalStates.oskOpen = !GlobalStates.oskOpen
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 0
                    text: "keyboard"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showMicToggle
            visible: Config.options.bar.utilButtons.showMicToggle
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_SOURCE@", "toggle"])
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 0
                    text: Pipewire.defaultAudioSource?.audio?.muted ? "mic_off" : "mic"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showDarkModeToggle
            visible: Config.options.bar.utilButtons.showDarkModeToggle
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: event => {
                    if (Appearance.m3colors.darkmode) {
                        Hyprland.dispatch(`exec ${Directories.wallpaperSwitchScriptPath} --mode light --noswitch`);
                    } else {
                        Hyprland.dispatch(`exec ${Directories.wallpaperSwitchScriptPath} --mode dark --noswitch`);
                    }
                }
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 0
                    text: Appearance.m3colors.darkmode ? "light_mode" : "dark_mode"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showPerformanceProfileToggle
            visible: Config.options.bar.utilButtons.showPerformanceProfileToggle
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: event => {
                    if (PowerProfiles.hasPerformanceProfile) {
                        switch(PowerProfiles.profile) {
                            case PowerProfile.PowerSaver: PowerProfiles.profile = PowerProfile.Balanced
                            break;
                            case PowerProfile.Balanced: PowerProfiles.profile = PowerProfile.Performance
                            break;
                            case PowerProfile.Performance: PowerProfiles.profile = PowerProfile.PowerSaver
                            break;
                        }
                    } else {
                        PowerProfiles.profile = PowerProfiles.profile == PowerProfile.Balanced ? PowerProfile.PowerSaver : PowerProfile.Balanced
                    }
                }
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 0
                    text: switch(PowerProfiles.profile) {
                        case PowerProfile.PowerSaver: return "energy_savings_leaf"
                        case PowerProfile.Balanced: return "airwave"
                        case PowerProfile.Performance: return "local_fire_department"
                    }
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showClipboardHistory
            visible: Config.options.bar.utilButtons.showClipboardHistory
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: {
                    root.clipboardPopupOpen = !root.clipboardPopupOpen;
                    if (root.clipboardPopupOpen) {
                        root.fetchHistory();
                    }
                }
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 1
                    text: "content_paste"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }
    }

    Loader {
        active: root.clipboardPopupOpen
        sourceComponent: PanelWindow {
            id: popupWindow
            visible: true
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            implicitWidth: 320
            implicitHeight: popupLayout.implicitHeight + 28
            WlrLayershell.namespace: "quickshell:clipboard"

            property real barThickness: Config.options.bar.vertical ? (Config.options.bar.sizes.width || 40) : (Config.options.bar.sizes.height || 40)
            
            anchors {
                top: !Config.options.bar.bottom || Config.options.bar.vertical
                bottom: Config.options.bar.bottom && !Config.options.bar.vertical
                left: !(Config.options.bar.vertical && Config.options.bar.bottom)
                right: Config.options.bar.vertical && Config.options.bar.bottom
            }

            margins {
                top: Config.options.bar.vertical ? (popupWindow.screen.height / 2 - implicitHeight / 2) : Appearance.sizes.barHeight + 8
                bottom: Appearance.sizes.barHeight + 8
                left: Config.options.bar.vertical ? (!Config.options.bar.bottom ? Appearance.sizes.verticalBarWidth + 8 : 0) : Math.max(0, root.mapToItem(null, 0, 0).x - implicitWidth / 2 + root.width / 2)
                right: Config.options.bar.vertical && Config.options.bar.bottom ? Appearance.sizes.verticalBarWidth + 8 : 0
            }

            Component.onCompleted: GlobalFocusGrab.addDismissable(popupWindow);
            Component.onDestruction: GlobalFocusGrab.removeDismissable(popupWindow);

            StyledRectangularShadow { target: popupBg }

            Rectangle {
                id: popupBg
                
                Connections {
                    target: GlobalFocusGrab
                    function onDismissed() { root.clipboardPopupOpen = false; }
                }

                anchors.fill: parent
                radius: Appearance.rounding.large
                color: Appearance.colors.colLayer0
                
                ColumnLayout {
                    id: popupLayout
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        MaterialSymbol {
                            text: "history"
                            iconSize: Appearance.font.pixelSize.larger
                            color: Appearance.colors.colOnSurfaceVariant
                        }
                        StyledText {
                            text: "Clipboard History"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.bold: true
                            color: Appearance.colors.colOnSurfaceVariant
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Appearance.colors.colBorder
                    }

                    Repeater {
                        model: root.clipHistory
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: Appearance.rounding.small
                            color: itemMouse.containsMouse ? Appearance.colors.colLayer1Hover : "transparent"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8
                                
                                StyledText {
                                    text: modelData.text.replace(/\s+/g, ' ')
                                    color: Appearance.colors.colOnLayer0
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    wrapMode: Text.NoWrap
                                    Layout.fillWidth: true
                                    clip: true
                                }
                            }
                            
                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.pasteItem(modelData.id)
                                }
                            }
                        }
                    }
                    
                    StyledText {
                        visible: root.clipHistory.length === 0
                        text: "History is empty"
                        color: Appearance.colors.colSubtext
                        font.pixelSize: Appearance.font.pixelSize.small
                        Layout.alignment: Qt.AlignHCenter
                        Layout.margins: 10
                    }
                }
            }
        }
    }
}
