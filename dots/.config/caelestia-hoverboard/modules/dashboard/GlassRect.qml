import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    property real radius: Tokens.rounding.large
    property color color: Qt.alpha(Colours.palette.m3surfaceContainerLow, 0.4)
    property bool clipContent: true
    
    default property alias content: innerContainer.data

    Rectangle {
        id: bg

        anchors.fill: parent
        color: root.color
        radius: root.radius

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 15
            shadowColor: Qt.alpha("#000000", 0.4)
        }
    }

    ClippingRectangle {
        id: innerContainer
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        clip: root.clipContent
    }
}
