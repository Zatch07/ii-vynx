pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

Item {
    id: root

    required property var visibilities
    readonly property bool needsKeyboard: (content.item as Content)?.needsKeyboard ?? false

    // A simple property to track the current tab internally, instead of the heavy DashboardState
    property int currentTab: 0

    readonly property real nonAnimHeight: state === "visible" ? ((content.item as Content)?.nonAnimHeight ?? 0) : 0

    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth || 854

    readonly property bool barIsTop: {
        const config = Weather.barConfigData?.bar;
        if (!config) return false;
        return config.bottom === false && config.vertical === false;
    }
    readonly property int barHeight: Weather.barConfigData?.bar?.sizes?.height ?? 45

    readonly property int activeTopMargin: barIsTop ? barHeight + 20 : 20

    state: visibilities.dashboard ? "visible" : "hidden"

    states: [
        State {
            name: "visible"
            PropertyChanges {
                target: root
                anchors.topMargin: activeTopMargin
                opacity: 1.0
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: root
                anchors.topMargin: -root.implicitHeight - 50
                opacity: 0.0
            }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"; to: "visible"
            ParallelAnimation {
                SpringAnimation {
                    target: root
                    property: "anchors.topMargin"
                    spring: 5.5
                    damping: 0.5
                    mass: 0.45
                }
                NumberAnimation {
                    target: root
                    property: "opacity"
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
        },
        Transition {
            from: "visible"; to: "hidden"
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        target: root
                        property: "anchors.topMargin"
                        duration: 200
                        easing.type: Easing.InBack
                    }
                    NumberAnimation {
                        target: root
                        property: "opacity"
                        duration: 150
                        easing.type: Easing.InQuad
                    }
                }
                ScriptAction {
                    script: Qt.quit()
                }
            }
        }
    ]

    Loader {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        active: visibilities.dashboard || root.opacity > 0

        sourceComponent: Content {
            visibilities: root.visibilities
            currentTab: root.currentTab
            onCurrentTabChanged: {
                if (root.currentTab !== currentTab) {
                    root.currentTab = currentTab;
                }
            }
        }
    }
}
