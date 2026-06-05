pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.services

Rectangle {
    id: root

    // Overall dashboard background
    color: Qt.alpha(Colours.palette.m3surface, 0.5)
    radius: Tokens.rounding.large * 1.5
    border.width: 1
    border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.3)

    required property var visibilities
    property int currentTab: 0

    readonly property bool needsKeyboard: false

    readonly property var dashboardTabs: [
        {
            component: dashComponent,
            iconName: "dashboard",
            text: qsTr("Dashboard")
        },
        {
            component: mediaComponent,
            iconName: "queue_music",
            text: qsTr("Media")
        },
        {
            component: performanceComponent,
            iconName: "speed",
            text: qsTr("Performance")
        },
        {
            component: weatherComponent,
            iconName: "cloud",
            text: qsTr("Weather")
        }
    ]

    readonly property real nonAnimWidth: view.implicitWidth + viewWrapper.anchors.margins * 2
    readonly property real nonAnimHeight: tabs.implicitHeight + tabs.anchors.topMargin + view.implicitHeight + viewWrapper.anchors.margins * 2

    implicitWidth: nonAnimWidth
    implicitHeight: nonAnimHeight

    Tabs {
        id: tabs

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Tokens.padding.normal
        anchors.margins: Tokens.padding.large

        nonAnimWidth: root.nonAnimWidth - anchors.margins * 2
        currentTab: root.currentTab
        onRequestTabChange: (newTab) => root.currentTab = newTab
        tabs: root.dashboardTabs
    }

    ClippingRectangle {
        id: viewWrapper

        anchors.top: tabs.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.padding.large

        radius: Tokens.rounding.normal
        color: "transparent"

        Flickable {
            id: view

            readonly property int currentIndex: root.currentTab
            readonly property Item currentItem: {
                repeater.count; // Trigger update on count change
                return repeater.itemAt(currentIndex);
            }

            anchors.fill: parent

            flickableDirection: Flickable.HorizontalFlick

            implicitWidth: currentItem?.implicitWidth ?? 0
            implicitHeight: currentItem?.implicitHeight ?? 0

            contentX: currentItem?.x ?? 0
            contentWidth: row.implicitWidth
            contentHeight: row.implicitHeight

            onContentXChanged: {
                if (!moving || !currentItem)
                    return;

                const x = contentX - currentItem.x;
                if (x > currentItem.implicitWidth / 2)
                    root.currentTab = Math.min(root.currentTab + 1, tabs.count - 1);
                else if (x < -currentItem.implicitWidth / 2)
                    root.currentTab = Math.max(root.currentTab - 1, 0);
            }

            onDragEnded: {
                if (!currentItem)
                    return;

                const x = contentX - currentItem.x;
                if (x > currentItem.implicitWidth / 10)
                    root.currentTab = Math.min(root.currentTab + 1, tabs.count - 1);
                else if (x < -currentItem.implicitWidth / 10)
                    root.currentTab = Math.max(root.currentTab - 1, 0);
                else
                    contentX = Qt.binding(() => currentItem?.x ?? 0);
            }

            RowLayout {
                id: row

                Repeater {
                    id: repeater

                    model: ScriptModel {
                        values: root.dashboardTabs
                    }

                    delegate: Loader {
                        id: paneLoader

                        required property int index
                        required property var modelData

                        Layout.alignment: Qt.AlignTop

                        sourceComponent: modelData.component

                        Component.onCompleted: active = Qt.binding(() => {
                            if (index === view.currentIndex)
                                return true;
                            const vx = Math.floor(view.visibleArea.xPosition * view.contentWidth);
                            const vex = Math.floor(vx + view.visibleArea.widthRatio * view.contentWidth);
                            return (vx >= x && vx <= x + implicitWidth) || (vex >= x && vex <= x + implicitWidth);
                        })
                    }
                }
            }

            Component {
                id: dashComponent

                Dash {
                    visibilities: root.visibilities
                }
            }

            Component {
                id: mediaComponent
                Media {
                    visibilities: root.visibilities
                }
            }

            Component {
                id: performanceComponent
                Performance {}
            }

            Component {
                id: weatherComponent
                WeatherTab {}
            }

            Behavior on contentX {
                Anim {}
            }
        }
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.EmphasizedLarge
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: Anim.EmphasizedLarge
        }
    }
}
