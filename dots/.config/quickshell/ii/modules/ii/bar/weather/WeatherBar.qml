pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Quickshell
import QtQuick
import QtQuick.Layouts
import "../cards"

MouseArea {
    id: root
    property bool vertical: false
    property bool hovered: false
    implicitWidth: root.vertical ? (rowLayout.implicitHeight + 10 * 2) : (rowLayout.implicitWidth + 10 * 2.5)
    implicitHeight: root.vertical ? (rowLayout.implicitWidth + 10 * 2.5) : (rowLayout.implicitHeight + 10 * 2)

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    onPressed: {
        if (mouse.button === Qt.RightButton) {
            Weather.getData();
            Quickshell.execDetached(["notify-send", 
                Translation.tr("Weather"), 
                Translation.tr("Refreshing (manually triggered)")
                , "-a", "Shell"
            ])
            mouse.accepted = false
        }
    }

    GridLayout {
        id: rowLayout
        anchors.centerIn: parent
        rotation: root.vertical ? 90 : 0

        columns: 2
        rows: 1

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: Appearance.font.pixelSize.large
            implicitHeight: Appearance.font.pixelSize.large
            
            property string currentIcon: Weather.data.currentIcon ?? "cloud"
            property bool isMoon: currentIcon.startsWith("moon_")

            MaterialSymbol {
                anchors.centerIn: parent
                visible: !parent.isMoon
                fill: 0
                text: parent.currentIcon
                iconSize: Appearance.font.pixelSize.large
                color: Appearance.colors.colOnLayer1
            }

            MoonPhaseIcon {
                anchors.centerIn: parent
                visible: parent.isMoon
                iconSize: Appearance.font.pixelSize.large
                color: Appearance.colors.colOnLayer1
                phase: parent.isMoon ? parseInt(parent.currentIcon.split("_")[1]) : 0
            }
        }

        StyledText {
            visible: true
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: Weather.data?.temp ?? "--°"
            Layout.alignment: Qt.AlignVCenter
        }
    }

    property bool compactMode: Config.options.bar.tooltips.compactPopups

    Loader {
        active: true
        sourceComponent: root.compactMode ? weatherPopupCompact : weatherPopup
    }
    
    Component {
        id: weatherPopupCompact

        WeatherPopupCompact {
            hoverTarget: root
        }
    }
    
    Component {
        id: weatherPopup

        WeatherPopup {
            hoverTarget: root
        }
    }
}
