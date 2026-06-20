pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    readonly property var keybinds: {
        const hasFilter = root.filter !== '';

        const defaultKeybinds = HyprlandKeybinds.defaultKeybinds.children ?? [];
        const userKeybinds = HyprlandKeybinds.userKeybinds.children ?? [];

        const unbinds = Config.options.cheatsheet.filterUnbinds ? parseUnbinds(userKeybinds) : [];
        return {
            children: [...(parseKeymaps(defaultKeybinds, unbinds) ?? []), ...(parseKeymaps(userKeybinds) ?? []),]
        };
    }
    property real spacing: 20
    property real titleSpacing: 7
    property real padding: 4
    property var filter: ''
    property var localWidth: 0
    property var localHeight: 0
    readonly property real _maxWidth: QsWindow?.window?.screen.width * 0.85 ?? 1400
    readonly property real _maxHeight: QsWindow?.window?.screen.height * 0.7 ?? 800
    implicitWidth: Math.min(flickable.implicitWidth, _maxWidth)
    implicitHeight: Math.min(flickable.implicitHeight, _maxHeight)
    // Excellent symbol explaination and source :
    // http://xahlee.info/comp/unicode_computing_symbols.html
    // https://www.nerdfonts.com/cheat-sheet
    property var macSymbolMap: ({
            "Ctrl": "󰘴",
            "Alt": "󰘵",
            "Shift": "󰘶",
            "Space": "󱁐",
            "Tab": "↹",
            "Equal": "󰇼",
            "Minus": "",
            "Print": "",
            "BackSpace": "󰭜",
            "Delete": "⌦",
            "Return": "󰌑",
            "Period": ".",
            "Escape": "⎋"
        })
    property var functionSymbolMap: ({
            "F1": "󱊫",
            "F2": "󱊬",
            "F3": "󱊭",
            "F4": "󱊮",
            "F5": "󱊯",
            "F6": "󱊰",
            "F7": "󱊱",
            "F8": "󱊲",
            "F9": "󱊳",
            "F10": "󱊴",
            "F11": "󱊵",
            "F12": "󱊶"
        })

    property var mouseSymbolMap: ({
            "mouse_up": "󱕐",
            "mouse_down": "󱕑",
            "mouse:272": "L󰍽",
            "mouse:273": "R󰍽",
            "Scroll ↑/↓": "󱕒",
            "Page_↑/↓": "⇞/⇟"
        })

    property var keyBlacklist: ["Super_L"]
    property var keySubstitutions: Object.assign({
        "Super": "",
        "mouse_up": "Scroll ↓"    // ikr, weird
        ,
        "mouse_down": "Scroll ↑"  // trust me bro
        ,
        "mouse:272": "LMB",
        "mouse:273": "RMB",
        "mouse:275": "MouseBack",
        "Slash": "/",
        "Hash": "#",
        "Return": "Enter"
    // "Shift": "",
    }, !!Config.options.cheatsheet.superKey ? {
        "Super": Config.options.cheatsheet.superKey
    } : {}, Config.options.cheatsheet.useMacSymbol ? macSymbolMap : {}, Config.options.cheatsheet.useFnSymbol ? functionSymbolMap : {}, Config.options.cheatsheet.useMouseSymbol ? mouseSymbolMap : {})

    property var categoryIcons: ({
        "Audio": "volume_up",
        "Layout": "view_quilt",
        "Window": "desktop_windows",
        "System": "settings",
        "Apps": "apps",
        "Misc": "category"
    })
    property var sectionShapes: [
        "squircle", "circle", "square", "hexagon"
    ]

    component KeyChip: Rectangle {
        id: chipRoot
        property string chipText
        property color textColor: Appearance.colors.colOnSurface
        property color bgColor: Appearance.colors.colSurfaceContainerLow

        implicitWidth: chipLabel.implicitWidth + 16
        implicitHeight: chipLabel.implicitHeight + 10
        radius: Appearance.rounding.small
        color: bgColor

        StyledText {
            id: chipLabel
            anchors.centerIn: parent
            text: chipRoot.chipText
            font.family: Appearance.font.family.monospace
            font.pixelSize: Config.options.cheatsheet.fontSize.key
            font.weight: Font.Bold
            color: chipRoot.textColor
        }
    }

    function parseKeymaps(cheatsheet, unbinds) {
        if (!unbinds) unbinds = [];
        if (!cheatsheet) return [];

        // Helper to recursively find all categories (sections with keybinds)
        function extractCategories(node, categories) {
            if (node.keybinds && node.keybinds.length > 0) {
                categories.push(node);
            }
            if (node.children) {
                node.children.forEach(child => extractCategories(child, categories));
            }
            return categories;
        }

        const allCategories = [];
        cheatsheet.forEach(child => {
            extractCategories(child, allCategories);
        });

        return allCategories.map(category => {
            const { keybinds } = category;
            const remappedKeybinds = keybinds.map(keybind => {
                let mods = [];

                for (var j = 0; j < keybind.mods.length; j++) {
                    mods[j] = keySubstitutions[keybind.mods[j]] || keybind.mods[j];
                }
                for (var i = 0; i < unbinds.length; i++) {
                    var unbindMod = unbinds[i].mods.length === keybind.mods.length;
                    for (var j = 0; j < keybind.mods.length; j++) {
                        if (unbinds[i].mods[j] && keybind.mods[j] !== unbinds[i].mods[j]) {
                            unbindMod = false;
                        }
                    }
                    if (unbindMod && keybind.key === unbinds[i].key) {
                        return !Config.options.cheatsheet.filterUnbinds;
                    }
                }

                if (!Config.options.cheatsheet.splitButtons) {
                    mods = [mods.join(' ')];
                    mods[0] += !keyBlacklist.includes(keybind.key) && keybind.mods[0]?.length ? ' ' : '';
                    mods[0] += !keyBlacklist.includes(keybind.key) ? (keySubstitutions[keybind.key] || keybind.key) : '';
                }
                return Object.assign({}, keybind, {
                    mods
                });
            });
            let fuzzyKeybinds;
            if (root.filter.trim() === '') {
                fuzzyKeybinds = remappedKeybinds;
            } else {
                fuzzyKeybinds = Fuzzy.go(root.filter.toLowerCase(), remappedKeybinds.map((keybind, index) => {
                    return {
                        name: Fuzzy.prepare(keybind.comment),
                        originalIndex: index
                    };
                }), {
                    all: true,
                    key: "name"
                }).map(result => remappedKeybinds[result.obj ? result.obj.originalIndex : remappedKeybinds.findIndex(k => k.comment === result.target)]).filter(Boolean);
            }
            
            const result = [];
            fuzzyKeybinds.forEach(keybind => {
                result.push({
                    "type": "keys",
                    "mods": keybind.mods,
                    "key": keybind.key
                });
                result.push({
                    "type": "comment",
                    "comment": keybind.comment
                });
            });

            return !!fuzzyKeybinds.length ? Object.assign({}, category, {
                keybinds: fuzzyKeybinds,
                result
            }) : null;
        }).filter(Boolean);
    }

    function parseUnbinds(cheatsheet, name) {
        if (!cheatsheet) return [];
        let unbinds = [];
        function extractUnbinds(node) {
            if (node.unbinds && Array.isArray(node.unbinds)) {
                node.unbinds.forEach(unbind => unbinds.push(unbind));
            }
            if (node.children) {
                node.children.forEach(child => extractUnbinds(child));
            }
        }
        cheatsheet.forEach(child => extractUnbinds(child));
        return unbinds;
    }

    onFocusChanged: focus => {
        if (focus) {
            root.localWidth = Math.max(root.localWidth, root._maxWidth);
            root.localHeight = Math.max(root.localHeight, root._maxHeight);
            filterField.forceActiveFocus();
        }
    }
    Toolbar {
        id: extraOptions
        z: 1
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 8
        }

        IconToolbarButton {
            implicitWidth: height
            text: Config.options.cheatsheet.filterUnbinds ? "filter_alt" : "filter_alt_off"
            onClicked: {
                Config.options.cheatsheet.filterUnbinds = !Config.options.cheatsheet.filterUnbinds;
            }
            StyledToolTip {
                text: Translation.tr("Toggle filter on system shortcuts unbind by the user")
            }
        }

        ToolbarTextField {
            id: filterField
            placeholderText: focus ? Translation.tr("Filter shortcuts") : Translation.tr("Hit \"/\" to filter")

            // Style
            clip: true
            font.pixelSize: Appearance.font.pixelSize.small

            // Search
            onTextChanged: {
                root.filter = text;
            }
        }

        IconToolbarButton {
            implicitWidth: height
            onClicked: {
                root.filter = filterField.text = '';
            }
            text: "close"
            StyledToolTip {
                text: Translation.tr("Clear filter")
            }
        }
    }
    PagePlaceholder {
        shown: keybinds.children.length === 0 && root.filter !== ''
        icon: "search_off"
        description: Translation.tr("No results")
        shape: MaterialShape.Shape.Ghostish
        descriptionHorizontalAlignment: Text.AlignHCenter
    }
    Flickable {
        id: flickable
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: extraOptions.top
            bottomMargin: 4
        }
        contentWidth: Math.max(row.implicitWidth, width)
        contentHeight: Math.max(row.implicitHeight, height)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 3000

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheelEvent => {
                const delta = -wheelEvent.angleDelta.y;
                if (delta !== 0) {
                    flickable.cancelFlick();
                    flickable.flick(delta * 15, 0);
                }
                wheelEvent.accepted = true;
            }
        }

        Flow { // Keybind columns
            id: row
            flow: Flow.TopToBottom
            height: flickable.height
            spacing: root.spacing
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: keybinds.children
                visible: !!keybinds.children.length

                delegate: Rectangle { // Section with real keybinds
                    id: keybindSection
                    required property var modelData
                    required property int index

                    visible: !!keybindSection.modelData.keybinds.length
                    implicitWidth: cardContent.implicitWidth + 32
                    implicitHeight: cardContent.implicitHeight + 32
                    color: Appearance.colors.colLayer4
                    radius: Appearance.rounding.large
                    clip: true

                    Column {
                        id: cardContent
                        anchors {
                            top: parent.top
                            left: parent.left
                            margins: 16
                        }
                        spacing: 12

                        Row {
                            spacing: 10

                            MaterialShape {
                                shapeString: root.sectionShapes[keybindSection.index % root.sectionShapes.length] || "squircle"
                                implicitSize: 32
                                color: Appearance.colors.colPrimaryContainer

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: root.categoryIcons[keybindSection.modelData.name] || "keyboard"
                                    iconSize: Appearance.font.pixelSize.normal
                                    fill: 1.0
                                    color: Appearance.colors.colOnPrimaryContainer
                                }
                            }

                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                font {
                                    family: Appearance.font.family.title
                                    pixelSize: Appearance.font.pixelSize.title
                                    weight: Font.Bold
                                }
                                color: Appearance.colors.colOnSurface
                                text: keybindSection.modelData.name || "Keybinds"
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            radius: 1
                            color: Appearance.colors.colOutlineVariant
                            opacity: 0.3
                        }

                        Column {
                            spacing: 8

                            Repeater {
                                model: keybindSection.modelData.keybinds
                                delegate: Row {
                                    required property var modelData
                                    spacing: 12

                                    Row {
                                        spacing: 4
                                        Repeater {
                                            model: modelData.mods
                                            delegate: KeyChip {
                                                required property var modelData
                                                chipText: root.keySubstitutions[modelData] || modelData
                                                bgColor: Appearance.colors.colSurfaceContainerLow
                                                textColor: Appearance.colors.colOnSurface
                                            }
                                        }
                                        StyledText {
                                            visible: Config.options.cheatsheet.splitButtons && !root.keyBlacklist.includes(modelData.key) && modelData.mods.length > 0
                                            text: "+"
                                            font.pixelSize: Config.options.cheatsheet.fontSize.key
                                            color: Appearance.colors.colPrimary
                                        }
                                        KeyChip {
                                            visible: Config.options.cheatsheet.splitButtons && !root.keyBlacklist.includes(modelData.key)
                                            chipText: root.keySubstitutions[modelData.key] || modelData.key
                                            bgColor: Appearance.colors.colPrimary
                                            textColor: Appearance.colors.colOnPrimary
                                        }
                                    }

                                    StyledText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font.pixelSize: Config.options.cheatsheet.fontSize.comment || Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colOnSurface
                                        opacity: 0.7
                                        text: modelData.comment || ""
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PagePlaceholder {
        shown: keybinds.children.length === 0 && root.filter !== ''
        icon: "search_off"
        description: Translation.tr("No results")
        shape: MaterialShape.Shape.Ghostish
        descriptionHorizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent
    }
}
