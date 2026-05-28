import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: page
    readonly property int index: 8
    property bool register: parent.register ?? false
    forceWidth: true

    property int rounding: 6
    property int borderGrab: 8
    property int borderSize: 1
    property int gapsIn: 4
    property int gapsOut: 5
    property string currentLayout: "dwindle"
    property bool blurEnabled: true
    property int blurSize: 10
    property bool shadowEnabled: true
    property bool dimInactive: true
    property bool animEnabled: true
    property real animSpeed: 5.0

    // --- Cursor Properties ---
    property string currentCursor: ""
    property int    currentCursorSize: 24
    property var    cursorSizes: ({})
    readonly property string sizesFilePath: Directories.shellConfig + "/custom_cursor_sizes.json"

    Process {
        id: readHyprConfigProc
        running: true
        command: ["python3", "/home/zatch/.local/bin/update_hypr_gui.py", "--read"]
        stdout: StdioCollector {
            onRead: data => {
                try {
                    let parsed = JSON.parse(data);
                    if (parsed) {
                        page.rounding = parsed.rounding;
                        page.borderGrab = parsed.border_grab;
                        page.borderSize = parsed.border_size;
                        page.gapsIn = parsed.gaps_in;
                        page.gapsOut = parsed.gaps_out;
                        page.currentLayout = parsed.layout;
                        page.blurEnabled = parsed.blur_enabled;
                        page.blurSize = parsed.blur_size;
                        page.shadowEnabled = parsed.shadow_enabled;
                        page.dimInactive = parsed.dim_inactive;
                        page.animEnabled = parsed.anim_enabled;
                        page.animSpeed = parsed.anim_speed;
                    }
                } catch (e) { }
            }
        }
    }

    // --- Cursor Processes ---
    Process {
        id: readSizesProc
        running: true
        command: ["cat", page.sizesFilePath]
        stdout: StdioCollector {
            onRead: data => {
                try {
                    let parsed = JSON.parse(data);
                    if (parsed) {
                        page.cursorSizes = parsed;
                        if (page.currentCursor && page.cursorSizes[page.currentCursor]) {
                            page.currentCursorSize = page.cursorSizes[page.currentCursor];
                        }
                    }
                } catch (e) {}
            }
        }
    }
    
    Process {
        id: getCursorProc
        running: true
        command: ["bash", "-c", "gsettings get org.gnome.desktop.interface cursor-theme | tr -d \"'\""]
        stdout: SplitParser {
            onRead: data => { 
                currentCursor = data.trim(); 
                if (page.cursorSizes[currentCursor]) {
                    currentCursorSize = page.cursorSizes[currentCursor];
                }
            }
        }
    }

    Process {
        id: getCursorSizeProc
        running: true
        command: ["bash", "-c", "gsettings get org.gnome.desktop.interface cursor-size"]
        stdout: SplitParser {
            onRead: data => {
                let v = parseInt(data.trim());
                if (!isNaN(v) && v > 0) {
                    if (!page.cursorSizes[page.currentCursor]) {
                        currentCursorSize = v;
                    }
                }
            }
        }
    }

    Process {
        id: listCursorsProc
        running: true
        command: ["bash", "-c", "~/.local/bin/generate_cursor_previews.sh"]
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim();
                if (line === "") return;
                let lines = line.split("\n");
                for (let l of lines) {
                    let bar = l.indexOf("|");
                    let name = bar >= 0 ? l.substring(0, bar) : l;
                    let preview = bar >= 0 ? l.substring(bar + 1) : "";
                    if (name !== "") cursorModel.append({ name: name, preview: preview });
                }
            }
        }
    }

    ListModel { id: cursorModel }
    
    function getPreviewFor(name) {
        for (let i = 0; i < cursorModel.count; i++) {
            if (cursorModel.get(i).name === name) return cursorModel.get(i).preview;
        }
        return "";
    }

    Timer {
        id: saveCursorTimer
        interval: 1000
        repeat: false
        onTriggered: {
            Quickshell.execDetached(["bash", "-c", "echo '" + JSON.stringify(page.cursorSizes) + "' > " + page.sizesFilePath]);
        }
    }

    function saveSize(theme, size) {
        if (!theme) return;
        let updated = page.cursorSizes;
        updated[theme] = size;
        page.cursorSizes = updated;
        saveCursorTimer.restart();
    }
    
    function applyCursorSize(size) {
        if (page.currentCursor === "") return;
        Quickshell.execDetached(["bash", "-c", "~/.local/bin/cursor-set '" + page.currentCursor + "' " + size]);
        saveSize(page.currentCursor, size);
    }

    Timer {
        id: saveHyprTimer
        interval: 300
        repeat: false
        onTriggered: {
            let cmd = ["python3", "/home/zatch/.local/bin/update_hypr_gui.py", 
                       "--rounding", page.rounding.toString(),
                       "--border_grab", page.borderGrab.toString(),
                       "--border_size", page.borderSize.toString(),
                       "--gaps_in", page.gapsIn.toString(),
                       "--gaps_out", page.gapsOut.toString(),
                       "--layout", page.currentLayout,
                       "--blur_enabled", page.blurEnabled ? "true" : "false",
                       "--blur_size", page.blurSize.toString(),
                       "--shadow_enabled", page.shadowEnabled ? "true" : "false",
                       "--dim_inactive", page.dimInactive ? "true" : "false",
                       "--anim_enabled", page.animEnabled ? "true" : "false",
                       "--anim_speed", page.animSpeed.toString()];
            Quickshell.execDetached(cmd);
        }
    }

    function saveHyprConfig() { saveHyprTimer.restart(); }

    ContentSection {
        icon: "near_me"
        title: Translation.tr("Cursors")
        
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 250 
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal
            clip: true

            StyledFlickable {
                id: cursorFlickable
                anchors.fill: parent
                contentHeight: cursorColumn.implicitHeight

                Column {
                    id: cursorColumn
                    width: cursorFlickable.width
                    spacing: 2
                    padding: 4

                    Repeater {
                        model: cursorModel
                        delegate: RippleButton {
                            id: cursorEntry
                            required property string name
                            required property string preview
                            required property int index

                            width: cursorColumn.width - cursorColumn.padding * 2
                            implicitHeight: 44
                            buttonRadius: Appearance.rounding.small
                            colBackground: name === currentCursor
                                ? Appearance.colors.colSecondaryContainer
                                : Appearance.colors.colLayer2
                            onClicked: {
                                let targetSize = page.cursorSizes[name] || page.currentCursorSize;
                                Quickshell.execDetached(["bash", "-c",
                                    "~/.local/bin/cursor-set '" + name + "' " + targetSize
                                ]);
                                currentCursor = name;
                                currentCursorSize = targetSize;
                                customSizeInput.value = targetSize;
                            }

                            contentItem: RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    color: Appearance.colors.colLayer3
                                    radius: 5
                                    visible: preview !== ""
                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 3
                                        source: preview !== "" ? ("file://" + preview) : ""
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                    }
                                }
                                MaterialSymbol {
                                    text: "near_me"
                                    iconSize: Appearance.font.pixelSize.larger
                                    color: Appearance.colors.colSubtext
                                    visible: preview === ""
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: name
                                    color: name === currentCursor
                                        ? Appearance.colors.colOnSecondaryContainer
                                        : Appearance.colors.colOnLayer3
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    elide: Text.ElideRight
                                }

                                MaterialSymbol {
                                    text: "check"
                                    iconSize: Appearance.font.pixelSize.larger
                                    color: Appearance.colors.colOnSecondaryContainer
                                    visible: name === currentCursor
                                }
                            }
                        }
                    }
                }
            }
        }

        // Cursor Size Control
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 14
                    rightMargin: 14
                }
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    color: Appearance.colors.colLayer3
                    radius: 5
                    property string currentPreview: page.getPreviewFor(page.currentCursor)
                    Image {
                        anchors.fill: parent
                        anchors.margins: 4
                        visible: parent.currentPreview !== ""
                        source: parent.currentPreview !== "" ? ("file://" + parent.currentPreview) : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "near_me"
                        iconSize: 20
                        color: Appearance.colors.colSubtext
                        visible: parent.currentPreview === ""
                    }
                }

                StyledText {
                    text: Translation.tr("Size")
                    color: Appearance.colors.colOnLayer2
                    font.pixelSize: Appearance.font.pixelSize.normal
                    Layout.fillWidth: true
                }

                Row {
                    spacing: 6
                    Repeater {
                        model: [16, 24, 32, 48, 64]
                        delegate: RippleButton {
                            id: presetChip
                            required property int modelData
                            implicitWidth: 40
                            implicitHeight: 32
                            buttonRadius: Appearance.rounding.small
                            colBackground: page.currentCursorSize === presetChip.modelData
                                ? Appearance.colors.colPrimaryContainer
                                : Appearance.colors.colLayer3
                            onClicked: {
                                page.currentCursorSize = presetChip.modelData;
                                page.applyCursorSize(presetChip.modelData);
                            }
                            contentItem: StyledText {
                                anchors.centerIn: parent
                                text: presetChip.modelData
                                color: page.currentCursorSize === presetChip.modelData
                                    ? Appearance.colors.colOnPrimaryContainer
                                    : Appearance.colors.colOnLayer3
                                font {
                                    pixelSize: Appearance.font.pixelSize.smaller
                                    family: Appearance.font.family.numbers
                                }
                            }
                        }
                    }
                }

                StyledSpinBox {
                    id: customSizeInput
                    from: 1
                    to: 256
                    value: page.currentCursorSize
                    implicitWidth: 100
                    baseHeight: 32
                }

                RippleButton {
                    implicitWidth: 50
                    implicitHeight: 32
                    buttonRadius: Appearance.rounding.small
                    colBackground: Appearance.colors.colPrimaryContainer
                    onClicked: {
                        page.currentCursorSize = customSizeInput.value;
                        page.applyCursorSize(customSizeInput.value);
                    }
                    contentItem: StyledText {
                        anchors.centerIn: parent
                        text: "Set"
                        color: Appearance.colors.colOnPrimaryContainer
                        font {
                            pixelSize: Appearance.font.pixelSize.smaller
                            bold: true
                        }
                    }
                }
            }
        }
    }

    ContentSection {
        icon: "space_dashboard"
        title: Translation.tr("Layout & Gaps")

        Item {
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.fillWidth: true
            implicitHeight: layoutRow.implicitHeight

            RowLayout {
                id: layoutRow
                anchors.fill: parent
                spacing: 10

                OptionalMaterialSymbol {
                    icon: "dashboard"
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr("Layout Style")
                    color: Appearance.colors.colOnSecondaryContainer
                }

                ConfigSelectionArray {
                    Layout.fillWidth: false
                    currentValue: page.currentLayout
                    options: [
                        { "displayName": "Dwindle", "value": "dwindle" },
                        { "displayName": "Master", "value": "master" }
                    ]
                    onSelected: newValue => {
                        page.currentLayout = newValue;
                        page.saveHyprConfig();
                    }
                }
            }
        }

        ConfigSpinBox {
            icon: "view_in_ar"
            text: Translation.tr("Inner gaps (between windows)")
            value: page.gapsIn
            from: 0
            to: 50
            stepSize: 1
            onValueChanged: {
                page.gapsIn = value;
                page.saveHyprConfig();
            }
        }

        ConfigSpinBox {
            icon: "padding"
            text: Translation.tr("Outer gaps (screen edge)")
            value: page.gapsOut
            from: 0
            to: 100
            stepSize: 1
            onValueChanged: {
                page.gapsOut = value;
                page.saveHyprConfig();
            }
        }
    }

    ContentSection {
        icon: "window"
        title: Translation.tr("Borders & Decoration")

        ConfigSpinBox {
            icon: "rounded_corner"
            text: Translation.tr("Window rounding")
            value: page.rounding
            from: 0
            to: 50
            stepSize: 1
            onValueChanged: {
                page.rounding = value;
                page.saveHyprConfig();
            }
        }

        ConfigSpinBox {
            icon: "border_all"
            text: Translation.tr("Border size")
            value: page.borderSize
            from: 0
            to: 20
            stepSize: 1
            onValueChanged: {
                page.borderSize = value;
                page.saveHyprConfig();
            }
        }

        ConfigSpinBox {
            icon: "pan_tool_alt"
            text: Translation.tr("Border grab area size")
            value: page.borderGrab
            from: 0
            to: 50
            stepSize: 1
            onValueChanged: {
                page.borderGrab = value;
                page.saveHyprConfig();
            }
        }

        ConfigSwitch {
            buttonIcon: "blur_on"
            text: Translation.tr("Enable background blur")
            checked: page.blurEnabled
            onCheckedChanged: {
                page.blurEnabled = checked;
                page.saveHyprConfig();
            }
        }

        ConfigSpinBox {
            icon: "lens_blur"
            text: Translation.tr("Blur size")
            value: page.blurSize
            from: 1
            to: 50
            stepSize: 1
            onValueChanged: {
                page.blurSize = value;
                page.saveHyprConfig();
            }
        }

        ConfigSwitch {
            buttonIcon: "layers"
            text: Translation.tr("Enable drop shadows")
            checked: page.shadowEnabled
            onCheckedChanged: {
                page.shadowEnabled = checked;
                page.saveHyprConfig();
            }
        }

        ConfigSwitch {
            buttonIcon: "brightness_medium"
            text: Translation.tr("Dim inactive windows")
            checked: page.dimInactive
            onCheckedChanged: {
                page.dimInactive = checked;
                page.saveHyprConfig();
            }
        }
    }

    ContentSection {
        icon: "animation"
        title: Translation.tr("Animations")

        ConfigSwitch {
            buttonIcon: "animation"
            text: Translation.tr("Enable animations")
            checked: page.animEnabled
            onCheckedChanged: {
                page.animEnabled = checked;
                page.saveHyprConfig();
            }
        }

        ConfigSpinBox {
            icon: "speed"
            text: Translation.tr("Global animation speed")
            value: Math.round(page.animSpeed * 10)
            from: 1
            to: 200
            stepSize: 1
            onValueChanged: {
                page.animSpeed = value / 10.0;
                page.saveHyprConfig();
            }
        }
    }
}
