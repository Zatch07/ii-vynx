import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.ii.sidebarDashboard.todo as SidebarTodo
import Quickshell

Item {
    id: root

    property real maxContentWidth: 1000
    property real maxHeight: 700

    implicitWidth: maxContentWidth
    implicitHeight: maxHeight

    property bool showAddDialog: false
    readonly property bool eventPopupVisible: showAddDialog
    property int dialogMargins: 20
    property int fabSize: 56
    property int fabMargins: 20

    property bool isValidKey: Todo.apiKey !== "" && Todo.apiKey !== "YOUR_TODOIST_API_KEY_HERE"

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_N && root.isValidKey) {
            root.showAddDialog = true;
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape && root.showAddDialog) {
            root.showAddDialog = false;
            event.accepted = true;
        }
    }

    Component.onCompleted: {
        if (root.isValidKey) Todo.refresh();
    }

    onVisibleChanged: {
        if (visible && root.isValidKey) Todo.refresh();
    }

    Item {
        anchors.fill: parent
        visible: root.isValidKey

        RowLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 24

            // Active Tasks Column
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.colors.colLayer4
                radius: Appearance.rounding.large
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Header Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        MaterialShape {
                            shapeString: "squircle"
                            implicitSize: 32
                            color: Appearance.colors.colPrimaryContainer

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "format_list_bulleted"
                                color: Appearance.colors.colOnPrimaryContainer
                                iconSize: Appearance.font.pixelSize.normal
                                fill: 1.0
                            }
                        }

                        StyledText {
                            text: Translation.tr("Active Tasks")
                            font.pixelSize: Appearance.font.pixelSize.title
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnSurface
                            Layout.fillWidth: true
                        }

                        MaterialLoadingIndicator {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            loading: Todo._isFetching
                            visible: Todo._isFetching && Todo.list.length > 0
                        }

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: Appearance.colors.colPrimaryContainer
                            StyledText {
                                anchors.centerIn: parent
                                text: activeList.taskList.length
                                color: Appearance.colors.colOnPrimaryContainer
                                font.weight: Font.Bold
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        radius: 1
                        color: Appearance.colors.colOutlineVariant
                        opacity: 0.3
                    }

                    // Task List
                    SidebarTodo.TaskList {
                        id: activeList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        listBottomPadding: root.fabSize + root.fabMargins * 2
                        taskFontSize: Appearance.font.pixelSize.larger
                        emptyPlaceholderIcon: "check_circle"
                        emptyPlaceholderText: Translation.tr("You're all caught up!")
                        taskList: Todo.list.map(function(item, i) {
                            return Object.assign({}, item, { "originalIndex": i });
                        }).filter(function(item) {
                            return !item.done;
                        })
                    }
                }
            }

            // Completed Tasks Column
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.colors.colLayer4
                radius: Appearance.rounding.large
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Header Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        MaterialShape {
                            shapeString: "circle"
                            implicitSize: 32
                            color: Appearance.colors.colSecondaryContainer

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "checklist"
                                color: Appearance.colors.colOnSecondaryContainer
                                iconSize: Appearance.font.pixelSize.normal
                                fill: 1.0
                            }
                        }

                        StyledText {
                            text: Translation.tr("Completed Tasks")
                            font.pixelSize: Appearance.font.pixelSize.title
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnSurface
                            Layout.fillWidth: true
                        }

                        MaterialLoadingIndicator {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            loading: Todo._isFetching
                            visible: Todo._isFetching && Todo.list.length > 0
                        }

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: Appearance.colors.colSecondaryContainer
                            StyledText {
                                anchors.centerIn: parent
                                text: doneList.taskList.length
                                color: Appearance.colors.colOnSecondaryContainer
                                font.weight: Font.Bold
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        radius: 1
                        color: Appearance.colors.colOutlineVariant
                        opacity: 0.3
                    }

                    // Task List
                    SidebarTodo.TaskList {
                        id: doneList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        listBottomPadding: 20
                        taskFontSize: Appearance.font.pixelSize.larger
                        emptyPlaceholderIcon: "checklist"
                        emptyPlaceholderText: Translation.tr("Finished tasks will go here")
                        taskList: Todo.list.map(function(item, i) {
                            return Object.assign({}, item, { "originalIndex": i });
                        }).filter(function(item) {
                            return item.done;
                        })
                    }
                }
            }
        }
    }

    // Global Loading Overlay for Empty State
    Rectangle {
        anchors.fill: parent
        color: Appearance.colors.colSurfaceContainer
        visible: Todo._isFetching && Todo.list.length === 0 && root.isValidKey
        z: 100
        radius: Appearance.rounding.large

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 24

            MaterialLoadingIndicator {
                Layout.alignment: Qt.AlignHCenter
                implicitSize: 160
                loading: parent.parent.visible
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Translation.tr("Fetching Tasks")
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnSurface
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Translation.tr("Connecting to Todoist and retrieving your tasks...")
                    font.pixelSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnSurfaceVariant
                    opacity: 0.8
                }
            }
        }
    }

    // Missing API Key Overlay
    Flickable {
        anchors.fill: parent
        anchors.margins: 40
        visible: !root.isValidKey
        contentHeight: setupCol.implicitHeight
        clip: true

        ColumnLayout {
            id: setupCol
            width: parent.width
            spacing: 24

            ColumnLayout {
                spacing: 8
                StyledText {
                    text: Translation.tr("Todoist Setup Required")
                    font.pixelSize: 42
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnSurface
                }
                StyledText {
                    text: Translation.tr("To use the Task Manager, you need to provide your Todoist API Key.")
                    font.pixelSize: Appearance.font.pixelSize.huge
                    color: Appearance.colors.colOnSurfaceVariant
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }

            // Tutorial Steps
            ColumnLayout {
                spacing: 16
                Layout.fillWidth: true

                Repeater {
                    model: [
                        { "step": "1", "text": "Go to Todoist Developer Integrations portal", "url": "https://app.todoist.com/app/settings/integrations/developer" },
                        { "step": "2", "text": "Create a new app (or select an existing one)", "url": "" },
                        { "step": "3", "text": "Generate a test token (API Key)", "url": "" },
                        { "step": "4", "text": "Copy the API Key into your quickshell .env file", "url": "" }
                    ]

                    delegate: RowLayout {
                        spacing: 16
                        Layout.fillWidth: true
                        
                        Rectangle {
                            width: 32; height: 32
                            radius: 16
                            color: Appearance.colors.colPrimaryContainer
                            StyledText {
                                anchors.centerIn: parent
                                text: modelData.step
                                color: Appearance.colors.colOnPrimaryContainer
                                font.weight: Font.Bold
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            StyledText {
                                text: Translation.tr(modelData.text)
                                color: Appearance.colors.colOnSurface
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                                font.pixelSize: Appearance.font.pixelSize.normal
                            }
                            StyledText {
                                visible: modelData.url !== ""
                                text: modelData.url
                                color: Appearance.colors.colPrimary
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Qt.openUrlExternally(modelData.url)
                                }
                            }
                        }
                    }
                }
            }

            // Action Buttons
            RowLayout {
                spacing: 16
                Layout.topMargin: 16
                Layout.alignment: Qt.AlignLeft

                RippleButton {
                    Layout.preferredHeight: 56
                    Layout.preferredWidth: 260
                    buttonRadius: Appearance.rounding.full
                    colBackground: Appearance.colors.colPrimary
                    colBackgroundHover: Appearance.colors.colPrimaryHover
                    onClicked: {
                        Quickshell.execDetached(["bash", "-c", "touch ~/.config/quickshell/ii/.env"]);
                        Todo.refresh();
                    }
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 12
                        MaterialSymbol { 
                            text: "refresh"
                            iconSize: 22
                            color: Appearance.colors.colOnPrimary 
                        }
                        StyledText {
                            text: Translation.tr("Check API Key")
                            color: Appearance.colors.colOnPrimary
                            font.weight: Font.Bold
                            font.pixelSize: Appearance.font.pixelSize.normal
                        }
                    }
                }

                RippleButton {
                    Layout.preferredHeight: 56
                    Layout.preferredWidth: 220
                    buttonRadius: Appearance.rounding.full
                    colBackground: Appearance.colors.colSurfaceContainerHigh
                    colBackgroundHover: Appearance.colors.colSurfaceContainerHighest
                    onClicked: {
                        Quickshell.execDetached(["bash", "-c", "xdg-open ~/.config/quickshell/ii"]);
                    }
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        MaterialSymbol { text: "edit"; iconSize: 22; color: Appearance.colors.colOnSurface }
                        StyledText {
                            text: Translation.tr("Open .env folder")
                            color: Appearance.colors.colOnSurface
                            font.weight: Font.Bold
                            font.pixelSize: Appearance.font.pixelSize.normal
                        }
                    }
                }
            }
            
            // Env Snippet
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: snippetText.implicitHeight + 40
                color: Appearance.colors.colSurfaceContainerLow
                radius: Appearance.rounding.small
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                
                StyledText {
                    id: snippetText
                    anchors.centerIn: parent
                    width: parent.width - 40
                    text: "export TODOIST_API_KEY=\"your_actual_key_here\""
                    font.family: Appearance.font.family.monospace
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                    wrapMode: Text.Wrap
                    lineHeight: 1.2
                }
            }
        }
    }

    // Add FAB
    StyledRectangularShadow {
        target: fabButton
        radius: fabButton.buttonRadius
        blur: 0.6 * Appearance.sizes.elevationMargin
        visible: root.isValidKey
    }

    FloatingActionButton {
        id: fabButton
        visible: root.isValidKey
        baseSize: root.fabSize
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.fabMargins + 24
        anchors.bottomMargin: root.fabMargins + 24
        onClicked: root.showAddDialog = true
        iconText: "add"
    }

    // Add Task Dialog Overlay
    Item {
        anchors.fill: parent
        z: 9999
        visible: opacity > 0 && root.isValidKey
        opacity: root.showAddDialog ? 1 : 0
        onVisibleChanged: {
            if (!visible) {
                todoInput.text = "";
                if (root.isValidKey) fabButton.focus = true;
            } else {
                todoInput.forceActiveFocus();
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.large
            color: Appearance.colors.colScrim

            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                preventStealing: true
                propagateComposedEvents: false
                onClicked: root.showAddDialog = false
            }
        }

        Rectangle {
            id: dialog
            function addTask() {
                if (todoInput.text.length > 0) {
                    Todo.addTask(todoInput.text);
                    todoInput.text = "";
                    root.showAddDialog = false;
                }
            }

            width: 400
            anchors.centerIn: parent
            implicitHeight: dialogColumnLayout.implicitHeight

            color: Appearance.m3colors.m3surfaceContainerHigh
            radius: Appearance.rounding.normal

            MouseArea {
                anchors.fill: parent
                preventStealing: true
                propagateComposedEvents: false
            }

            ColumnLayout {
                id: dialogColumnLayout
                anchors.fill: parent
                spacing: 16

                StyledText {
                    Layout.topMargin: 20
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.alignment: Qt.AlignLeft
                    color: Appearance.m3colors.m3onSurface
                    font.pixelSize: Appearance.font.pixelSize.larger
                    text: Translation.tr("Add task")
                }

                TextField {
                    id: todoInput
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    padding: 12
                    color: activeFocus ? Appearance.m3colors.m3onSurface : Appearance.m3colors.m3onSurfaceVariant
                    renderType: Text.NativeRendering
                    selectedTextColor: Appearance.m3colors.m3onSecondaryContainer
                    selectionColor: Appearance.colors.colSecondaryContainer
                    placeholderText: Translation.tr("Task description")
                    placeholderTextColor: Appearance.m3colors.m3outline
                    focus: root.showAddDialog
                    onAccepted: dialog.addTask()

                    background: Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.small
                        border.width: 2
                        border.color: todoInput.activeFocus ? Appearance.colors.colPrimary : Appearance.m3colors.m3outline
                        color: "transparent"
                    }

                    cursorDelegate: Rectangle {
                        width: 1
                        color: todoInput.activeFocus ? Appearance.colors.colPrimary : "transparent"
                        radius: 1
                    }
                }

                RowLayout {
                    Layout.bottomMargin: 20
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.alignment: Qt.AlignRight
                    spacing: 8

                    DialogButton {
                        buttonText: Translation.tr("Cancel")
                        onClicked: root.showAddDialog = false
                    }

                    DialogButton {
                        buttonText: Translation.tr("Add")
                        enabled: todoInput.text.length > 0
                        onClicked: dialog.addTask()
                    }
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.animation.elementMoveFast.duration
                easing.type: Appearance.animation.elementMoveFast.type
                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
            }
        }
    }
}
