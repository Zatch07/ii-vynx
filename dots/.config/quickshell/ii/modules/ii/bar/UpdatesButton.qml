import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Quickshell
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    implicitWidth: rowLayout.implicitWidth + 10 * 2
    implicitHeight: Appearance.sizes.barHeight
    
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    
    // 🔍 Visibility Logic (Only show if >= 200 updates)
    function updateVisibility() {
        if (typeof rootItem !== "undefined") {
            rootItem.toggleVisible(Number(Updates.count) >= 200);
        }
    }

    Connections {
        target: Updates
        function onCountChanged() { root.updateVisibility(); }
    }

    Component.onCompleted: root.updateVisibility();

    onClicked: {
        // 🚀 Always use yay in kitty for reliability
        Quickshell.execDetached(["kitty", "-1", "-e", "yay"]);
    }

    RowLayout {
        id: rowLayout
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            text: "update"
            iconSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnLayer1
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: updatesText.implicitWidth
            implicitHeight: updatesText.implicitHeight

            StyledText {
                id: updatesText
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
                text: Updates.count
            }
        }
    }

    UpdatesPopup {
       hoverTarget: root
    }
}
