import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import Qt5Compat.GraphicalEffects

Item {
    id: lyricLineItem
    required property string text
    property bool highlight: false
    property bool useGradient: false
    property string gradientDirection: "top"
    property bool reallyUseGradient: useGradient

    property real defaultLyricsSize: Appearance.font.pixelSize.hugeass * 1.5
    property int textHorizontalAlignment: Text.AlignHCenter
    property real gradientDensity: 1.0

    width: parent.width
    height: lyricScroller.rowHeight
    transformOrigin: lyricLineItem.textHorizontalAlignment === Text.AlignLeft  ? Item.Left  :
                 lyricLineItem.textHorizontalAlignment === Text.AlignRight ? Item.Right :
                                                                              Item.Center

    property real currentLyricsSize: defaultLyricsSize

    property bool changeTextWeight: false

    StyledText {
        id: lyricText
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        text: lyricLineItem.text
        color: lyricLineItem.highlight ? Appearance.colors.colOnLayer0 : Appearance.colors.colSubtext
        font.pixelSize: lyricLineItem.currentLyricsSize * (lyricLineItem.highlight ? 1.2 : 1.0)
        font.weight: changeTextWeight ? lyricLineItem.highlight ? Font.Bold : Font.Medium : Font.Medium
        horizontalAlignment: lyricLineItem.textHorizontalAlignment
        verticalAlignment: Text.AlignVCenter
        visible: !lyricLineItem.reallyUseGradient
        wrapMode: Text.WordWrap
    }

    Item {
        width: parent.width
        height: lyricText2.implicitHeight
        anchors.verticalCenter: parent.verticalCenter
        visible: lyricLineItem.reallyUseGradient
        layer.enabled: visible
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: lyricLineItem.width
                height: lyricText2.implicitHeight
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: lyricLineItem.gradientDirection === "top" ? Qt.rgba(0,0,0,gradientDensity) : "black"
                    }
                    GradientStop {
                        position: 1.0
                        color: lyricLineItem.gradientDirection === "top" ? "black" : Qt.rgba(0,0,0,gradientDensity)
                    }
                }
            }
        }

        StyledText {
            id: lyricText2
            anchors.fill: parent
            text: lyricLineItem.text
            color: Appearance.colors.colSubtext
            font.pixelSize: lyricLineItem.currentLyricsSize
            font.weight: Font.Medium
            horizontalAlignment: lyricLineItem.textHorizontalAlignment
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
    }
}