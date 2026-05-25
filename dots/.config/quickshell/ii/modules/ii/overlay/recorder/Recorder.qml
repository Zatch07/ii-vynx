pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.overlay
import Qt.labs.platform

StyledOverlayWidget {
    id: root
    minimumWidth: 360
    minimumHeight: 140

    FileDialog {
        id: videoFileDialog
        title: "Select a Video to Edit"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Video files (*.mp4 *.mkv *.webm *.mov *.avi)", "All files (*)"]
        onAccepted: {
            let path = file.toString();
            if (path.startsWith("file://")) {
                path = path.substring(7);
            }
            GlobalStates.launchVideoEditor(path);
        }
    }

    contentItem: OverlayBackground {
        id: contentItem
        radius: root.contentRadius
        property real padding: 8
        ColumnLayout {
            id: contentColumn
            anchors.centerIn: parent
            spacing: 10

            Row {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spacing: 10

                BigRecorderButton {
                    materialSymbol: "screenshot_region"
                    name: "Screenshot region"
                    onClicked: {
                        GlobalStates.overlayOpen = false;
                        Quickshell.execDetached(["qs", "-p", Quickshell.shellPath(""), "ipc", "call", "region", "screenshot"]);
                    }
                }

                BigRecorderButton {
                    materialSymbol: "photo_camera"
                    name: "Screenshot"
                    onClicked: {
                        GlobalStates.overlayOpen = false;
                        Quickshell.execDetached(["bash", "-c", "grim - | wl-copy"]);
                    }
                }

                BigRecorderButton {
                    materialSymbol: "screen_record"
                    name: "Record region"
                    onClicked: {
                        GlobalStates.overlayOpen = false;
                        Quickshell.execDetached(["qs", "-p", Quickshell.shellPath(""), "ipc", "call", "region", "recordWithSound"]);
                    }
                }
                
                BigRecorderButton {
                    materialSymbol: "capture"
                    name: "Record screen"
                    onClicked: {
                        GlobalStates.overlayOpen = false;
                        Quickshell.execDetached([Directories.recordScriptPath, "--fullscreen", "--sound"]);
                    }
                }
            }

            Row {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spacing: 10

                RippleButton {
                    implicitWidth: 150
                    implicitHeight: 36
                    readonly property int fullRadius: Config.options.appearance.sharpMode ? Appearance.rounding.full : height / 2
                    buttonRadius: fullRadius
                    colBackground: Appearance.colors.colLayer3
                    colBackgroundHover: Appearance.colors.colLayer3Hover
                    colRipple: Appearance.colors.colLayer3Active
                    onClicked: {
                        GlobalStates.overlayOpen = false;
                        Qt.openUrlExternally(`file://${Config.options.screenRecord.savePath}`);
                    }
                    contentItem: Row {
                        anchors.centerIn: parent
                        spacing: 6
                        MaterialSymbol {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "animated_images"
                            iconSize: 18
                        }
                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Translation.tr("Open folder")
                            font.pixelSize: 13
                        }
                    }
                }

                RippleButton {
                    implicitWidth: 150
                    implicitHeight: 36
                    readonly property int fullRadius: Config.options.appearance.sharpMode ? Appearance.rounding.full : height / 2
                    buttonRadius: fullRadius
                    colBackground: Appearance.colors.colLayer3
                    colBackgroundHover: Appearance.colors.colLayer3Hover
                    colRipple: Appearance.colors.colLayer3Active
                    onClicked: {
                        GlobalStates.overlayOpen = false;
                        videoFileDialog.open();
                    }
                    contentItem: Row {
                        anchors.centerIn: parent
                        spacing: 6
                        MaterialSymbol {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "video_file"
                            iconSize: 18
                        }
                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Translation.tr("Edit video")
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }
    }

    component BigRecorderButton: RippleButton {
        id: bigButton
        required property string materialSymbol
        required property string name
        implicitHeight: 66
        implicitWidth: 66
        readonly property int fullRadius: Config.options.appearance.sharpMode ? Appearance.rounding.full : height / 2
        buttonRadius: fullRadius

        colBackground: Appearance.colors.colLayer3
        colBackgroundHover: Appearance.colors.colLayer3Hover
        colRipple: Appearance.colors.colLayer3Active

        contentItem: MaterialSymbol {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: bigButton.materialSymbol
            iconSize: 28
        }

        StyledToolTip {
            text: bigButton.name
        }
    }
}
