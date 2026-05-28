pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ContentPage {
    id: extrasPage
    forceWidth: true

    property string currentCursor: ""
    property int    currentCursorSize: 24
    property var    cursorSizes: ({}) // Mapping of theme -> size
    
    property string currentShellTheme: "vynx" 

    // ── Persistence ─────────────────────────────────────────────────────────
    
    readonly property string sizesFilePath: Directories.shellConfig + "/custom_cursor_sizes.json"

    Process {
        id: readSizesProc
        running: true
        command: ["cat", extrasPage.sizesFilePath]
        stdout: StdioCollector {
            onRead: data => {
                try {
                    let parsed = JSON.parse(data);
                    if (parsed) {
                        extrasPage.cursorSizes = parsed;
                        if (extrasPage.currentCursor && extrasPage.cursorSizes[extrasPage.currentCursor]) {
                            extrasPage.currentCursorSize = extrasPage.cursorSizes[extrasPage.currentCursor];
                        }
                    }
                } catch (e) {}
            }
        }
    }

    Timer {
        id: saveTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (extrasPage.currentCursor === "") return;
            let json = JSON.stringify(extrasPage.cursorSizes);
            let cmd = `echo '${json}' > '${extrasPage.sizesFilePath}'`;
            Quickshell.execDetached(["bash", "-c", cmd]);
        }
    }

    function saveSize(theme, size) {
        if (!theme) return;
        let updated = extrasPage.cursorSizes;
        updated[theme] = size;
        extrasPage.cursorSizes = updated;
        saveTimer.restart();
    }

    // ── Shell Theme Logic ───────────────────────────────────────────────────

    Process {
        id: checkShellThemeProc
        running: true
        command: ["readlink", "-f", "/home/zatch/.config/quickshell/ii"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("pacman-v2")) currentShellTheme = "pacman-v2";
                else if (data.includes("pacman")) currentShellTheme = "pacman";
                else currentShellTheme = "vynx";
            }
        }
    }

    function switchShellTheme(theme) {
        let path = "themes/vynx";
        if (theme === "pacman") path = "themes/pacman";
        else if (theme === "pacman-v2") path = "themes/pacman-v2";
        
        let cmd = `ln -sfT ~/.config/quickshell/${path} ~/.config/quickshell/ii && touch ~/.config/quickshell/ii/shell.qml`;
        Quickshell.execDetached(["bash", "-c", cmd]);
        currentShellTheme = theme;
    }

    // ── Get current state ────────────────────────────────────────────────────

    Process {
        id: getCursorProc
        running: true
        command: ["bash", "-c", "gsettings get org.gnome.desktop.interface cursor-theme | tr -d \"'\""]
        stdout: SplitParser {
            onRead: data => { 
                currentCursor = data.trim(); 
                if (extrasPage.cursorSizes[currentCursor]) {
                    currentCursorSize = extrasPage.cursorSizes[currentCursor];
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
                    if (!extrasPage.cursorSizes[extrasPage.currentCursor]) {
                        currentCursorSize = v;
                    }
                }
            }
        }
    }

    function applyCursorSize(size) {
        if (extrasPage.currentCursor === "") return;
        Quickshell.execDetached(["bash", "-c", "~/.local/bin/cursor-set '" + extrasPage.currentCursor + "' " + size]);
        saveSize(extrasPage.currentCursor, size);
    }

    // ── List available options ───────────────────────────────────────────────

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

    // ── UI ───────────────────────────────────────────────────────────────────

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // 🟢 Section 1: Shell Theme Switcher
        ContentSection {
            icon: "palette"
            title: Translation.tr("Shell Theme")
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 60
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.normal

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 8

                    StyledText {
                        text: Translation.tr("Active Layout")
                        color: Appearance.colors.colOnLayer2
                        Layout.fillWidth: true
                    }

                    // Vynx Toggle
                    RippleButton {
                        implicitWidth: 80
                        implicitHeight: 36
                        buttonRadius: Appearance.rounding.small
                        colBackground: extrasPage.currentShellTheme === "vynx" 
                            ? Appearance.colors.colPrimaryContainer 
                            : Appearance.colors.colLayer3
                        onClicked: extrasPage.switchShellTheme("vynx")
                        contentItem: StyledText {
                            anchors.centerIn: parent
                            text: "Vynx II"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: extrasPage.currentShellTheme === "vynx" 
                                ? Appearance.colors.colOnPrimaryContainer 
                                : Appearance.colors.colOnLayer3
                        }
                    }

                    // Pacman V1 Toggle
                    RippleButton {
                        implicitWidth: 80
                        implicitHeight: 36
                        buttonRadius: Appearance.rounding.small
                        colBackground: extrasPage.currentShellTheme === "pacman" 
                            ? Appearance.colors.colPrimaryContainer 
                            : Appearance.colors.colLayer3
                        onClicked: extrasPage.switchShellTheme("pacman")
                        contentItem: StyledText {
                            anchors.centerIn: parent
                            text: "Classic"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: extrasPage.currentShellTheme === "pacman" 
                                ? Appearance.colors.colOnPrimaryContainer 
                                : Appearance.colors.colOnLayer3
                        }
                    }

                    // Pacman V2 Toggle (THE NEW ONE)
                    RippleButton {
                        implicitWidth: 90
                        implicitHeight: 36
                        buttonRadius: Appearance.rounding.small
                        colBackground: extrasPage.currentShellTheme === "pacman-v2" 
                            ? Appearance.colors.colPrimaryContainer 
                            : Appearance.colors.colLayer3
                        onClicked: extrasPage.switchShellTheme("pacman-v2")
                        contentItem: StyledText {
                            anchors.centerIn: parent
                            text: "Pacman V2"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: extrasPage.currentShellTheme === "pacman-v2" 
                                ? Appearance.colors.colOnPrimaryContainer 
                                : Appearance.colors.colOnLayer3
                        }
                    }
                }
            }
        }

        // 🔵 Section 2: Cursors
        ContentSection {
            icon: "near_me"
            title: Translation.tr("Cursors")
            Layout.fillWidth: true

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
                                    : ColorUtils.transparentize(Appearance.colors.colLayer3)
                                onClicked: {
                                    let targetSize = extrasPage.cursorSizes[name] || extrasPage.currentCursorSize;
                                    Quickshell.execDetached(["bash", "-c",
                                        "~/.local/bin/cursor-set " + name + " " + targetSize
                                    ]);
                                    currentCursor = name;
                                    currentCursorSize = targetSize;
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
        }

        // 🟡 Section 3: Cursor Size
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
                    property string currentPreview: extrasPage.getPreviewFor(extrasPage.currentCursor)
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
                            colBackground: extrasPage.currentCursorSize === presetChip.modelData
                                ? Appearance.colors.colPrimaryContainer
                                : Appearance.colors.colLayer3
                            onClicked: {
                                extrasPage.currentCursorSize = presetChip.modelData;
                                extrasPage.applyCursorSize(presetChip.modelData);
                            }
                            contentItem: StyledText {
                                anchors.centerIn: parent
                                text: presetChip.modelData
                                color: extrasPage.currentCursorSize === presetChip.modelData
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
                    value: extrasPage.currentCursorSize
                    implicitWidth: 100
                    baseHeight: 32
                }

                RippleButton {
                    implicitWidth: 50
                    implicitHeight: 32
                    buttonRadius: Appearance.rounding.small
                    colBackground: Appearance.colors.colPrimaryContainer
                    onClicked: {
                        extrasPage.currentCursorSize = customSizeInput.value;
                        extrasPage.applyCursorSize(customSizeInput.value);
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
}
