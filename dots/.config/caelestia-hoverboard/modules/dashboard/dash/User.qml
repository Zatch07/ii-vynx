import QtQuick
import Caelestia.Config
import qs.components
import qs.components.effects
import qs.components.images
import qs.services
import qs.utils

Row {
    id: root

    required property var visibilities

    padding: Tokens.padding.large
    spacing: Tokens.spacing.normal

    StyledClippingRect {
        implicitWidth: info.implicitHeight
        implicitHeight: info.implicitHeight

        radius: Tokens.rounding.large
        color: "transparent"

        MaterialIcon {
            anchors.centerIn: parent

            text: "person"
            fill: 1
            grade: 200
            font.pointSize: Math.floor(info.implicitHeight / 2) || 1
            visible: pfp.status !== Image.Ready
        }

        CachingImage {
            id: pfp

            anchors.fill: parent
            path: `${Paths.home}/.face`
        }
    }

    Column {
        id: info

        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacing.normal

        Item {
            id: line

            implicitWidth: icon.implicitWidth + text.width + text.anchors.leftMargin
            implicitHeight: Math.max(icon.implicitHeight, text.implicitHeight)

            ColouredIcon {
                id: icon

                anchors.left: parent.left
                anchors.leftMargin: (Tokens.sizes.dashboard.infoIconSize - implicitWidth) / 2

                source: SysInfo.osLogo
                implicitSize: Math.floor(Tokens.font.size.normal * 1.34)
                colour: Colours.palette.m3primary
            }

            StyledText {
                id: text

                anchors.verticalCenter: icon.verticalCenter
                anchors.left: icon.right
                anchors.leftMargin: icon.anchors.leftMargin
                text: `:  ${SysInfo.osPrettyName || SysInfo.osName}`
                font.pointSize: Tokens.font.size.normal

                width: Tokens.sizes.dashboard.infoWidth
                elide: Text.ElideRight
            }
        }

        InfoLine {
            icon: "select_window_2"
            text: SysInfo.wm
            colour: Colours.palette.m3secondary
        }

        InfoLine {
            id: uptime

            icon: "timer"
            text: qsTr("up %1").arg(SysInfo.uptime)
            colour: Colours.palette.m3tertiary
        }
    }

    component InfoLine: Item {
        id: line

        required property string icon
        required property string text
        required property color colour

        implicitWidth: icon.implicitWidth + text.width + text.anchors.leftMargin
        implicitHeight: Math.max(icon.implicitHeight, text.implicitHeight)

        MaterialIcon {
            id: icon

            anchors.left: parent.left
            anchors.leftMargin: (Tokens.sizes.dashboard.infoIconSize - implicitWidth) / 2

            fill: 1
            text: line.icon
            color: line.colour
            font.pointSize: Tokens.font.size.normal
        }

        StyledText {
            id: text

            anchors.verticalCenter: icon.verticalCenter
            anchors.left: icon.right
            anchors.leftMargin: icon.anchors.leftMargin
            text: `:  ${line.text}`
            font.pointSize: Tokens.font.size.normal

            width: Tokens.sizes.dashboard.infoWidth
            elide: Text.ElideRight
        }
    }
}
