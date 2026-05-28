import "../../../quickshell/ii"
import "../../../quickshell/ii/services"
import "../../../quickshell/ii/modules/common"
import "../../../quickshell/ii/modules/common/functions"
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

// Slanted wallpaper picker — adapted from ilyamiro/nixos-configuration
// Bridges into the existing end-4 Wallpapers.qml backend for full
// Matugen / mpvpaper / switchwall.sh integration.
Item {
    id: root
    
    signal closeRequested()
    signal dismissFinished()

    property bool isDismissing: false
    property int unloadedRadius: -1

    Timer {
        id: unloadTimer
        interval: 40
        repeat: true
        running: false
        onTriggered: {
            root.unloadedRadius += 1
            if (root.unloadedRadius >= 8) {
                unloadTimer.stop()
                root.dismissFinished()
            }
        }
    }

    function requestClose() {
        if (isDismissing) return
        isDismissing = true
        unloadedRadius = -1
        tabBarOpacity = 0
        unloadTimer.start()
        root.closeRequested()
    }

    readonly property string thumbDir: "file:///home/zatch/.cache/wallpaper_picker/thumbs"
    readonly property string srcDir: "/home/zatch/Pictures/Wallpapers"
    readonly property string weDir: "/home/zatch/Pictures/Wallpapers/WallpaperEngine"
    property bool useDarkMode: true

    // State for tabs: 0 = Static, 1 = Wallpaper Engine
    property int currentTab: 0
    onCurrentTabChanged: {
        if (view) {
            view.currentIndex = 0;
            view.positionViewAtIndex(0, ListView.Beginning);
        }
        entryAnimTimer.restart()
    }

    // Slant geometry
    readonly property int itemWidth: 300
    readonly property int itemHeight: 420
    readonly property int borderWidth: 3
    readonly property real skewFactor: -0.35

    // ── Entry animation ─────────────────────────────────────────────────
    property int _entryRevealRing: 0

    Timer {
        id: entryAnimTimer
        interval: 200  // Let Hyprland slide-down animation finish first!
        running: true
        repeat: false
        onTriggered: {
            root._entryRevealRing++
            // Fade tab bar in after the last nearby card finishes (~750ms total)
            tabBarRevealTimer.restart()
        }
    }

    // Tab bar reveal — delayed until after card animations settle
    property real tabBarOpacity: 0
    Timer {
        id: tabBarRevealTimer
        interval: 600
        running: false
        repeat: false
        onTriggered: root.tabBarOpacity = 1
    }

    property string currentWallPath: ""

    Process {
        command: ["jq", "-r", ".background.wallpaperPath", "/home/zatch/.config/illogical-impulse/config.json"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let p = text.trim();
                if (p && p !== "null") {
                    root.currentWallPath = p;
                }
                root.focusCurrentWallpaper();
            }
        }
    }

    property bool _focusDone: false
    function focusCurrentWallpaper() {
        if (_focusDone) return
        let currentWall = root.currentWallPath;
        if (!currentWall || currentWall.length === 0) return

        if (currentWall.indexOf("[WE-") !== -1) {
            if (weModel.status !== FolderListModel.Ready) return
            // Ensure we are on the WE tab
            if (root.currentTab !== 1) root.currentTab = 1
            const currentDirName = currentWall.split("/").pop()
            
            for (let i = 0; i < weModel.count; i++) {
                if (weModel.get(i, "fileName") === currentDirName) {
                    view.currentIndex = i
                    view.positionViewAtIndex(i, ListView.Center)
                    _focusDone = true
                    return
                }
            }
        } else {
            if (thumbModel.status !== FolderListModel.Ready) return
            
            const currentName = currentWall.split("/").pop()
            const targetThumb = currentName + ".jpg"
            for (let i = 0; i < thumbModel.count; i++) {
                let fName = thumbModel.get(i, "fileName")
                if (fName === targetThumb || fName === "000_" + targetThumb) {
                    view.currentIndex = i
                    view.positionViewAtIndex(i, ListView.Center)
                    _focusDone = true
                    return
                }
            }
        }
    }

    // ── Keyboard navigation ─────────────────────────────────────────────────
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.requestClose()
            event.accepted = true
        } else if (event.key === Qt.Key_Left) {
            view.decrementCurrentIndex()
            event.accepted = true
        } else if (event.key === Qt.Key_Right) {
            view.incrementCurrentIndex()
            event.accepted = true
        } else if (event.key === Qt.Key_A) {
            // Switch to Static tab
            root.currentTab = 0
            event.accepted = true
        } else if (event.key === Qt.Key_D) {
            // Switch to WE tab
            root.currentTab = 1
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (view.currentItem) view.currentItem.pickWallpaper()
            event.accepted = true
        }
    }

    // ── Tab Bar ─────────────────────────────────────────────────────────────
    Row {
        id: tabBar
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        
        // INCREASE THIS: Pushes the tabs further down from the top of the screen
        anchors.topMargin: 0 
        
        spacing: 30
        height: 45
        z: 20

        // Hide until card animations complete
        opacity: root.tabBarOpacity
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

        // Tab: Static
        Item {
            width: 200
            height: parent.height

            Rectangle {
                anchors.fill: parent
                // Darker background when selected
                color: root.currentTab === 0 ? "#B0000000" : "#20000000"
                border.color: root.currentTab === 0 ? "white" : "#40FFFFFF"
                border.width: 2
                
                // Apply the exact same slant as the cards!
                transform: Matrix4x4 {
                    property real s: root.skewFactor
                    matrix: Qt.matrix4x4(1, s, 0, 0,
                                         0, 1, 0, 0,
                                         0, 0, 1, 0,
                                         0, 0, 0, 1)
                }

                Behavior on color { ColorAnimation { duration: 250 } }
                Behavior on border.color { ColorAnimation { duration: 250 } }
            }

            Text {
                anchors.centerIn: parent
                text: "Static & Web"
                font.pixelSize: 20
                font.bold: root.currentTab === 0
                color: root.currentTab === 0 ? "white" : "#A0FFFFFF"
                Behavior on color { ColorAnimation { duration: 250 } }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.currentTab = 0
                // Fix the "Ghost Click": Make the clickable area visually identical to the slanted box
                transform: Matrix4x4 {
                    property real s: root.skewFactor
                    matrix: Qt.matrix4x4(1, s, 0, 0,
                                         0, 1, 0, 0,
                                         0, 0, 1, 0,
                                         0, 0, 0, 1)
                }
            }
        }

        // Tab: Wallpaper Engine
        Item {
            width: 240
            height: parent.height

            Rectangle {
                anchors.fill: parent
                color: root.currentTab === 1 ? "#B0000000" : "#20000000"
                border.color: root.currentTab === 1 ? "white" : "#40FFFFFF"
                border.width: 2
                
                transform: Matrix4x4 {
                    property real s: root.skewFactor
                    matrix: Qt.matrix4x4(1, s, 0, 0,
                                         0, 1, 0, 0,
                                         0, 0, 1, 0,
                                         0, 0, 0, 1)
                }

                Behavior on color { ColorAnimation { duration: 250 } }
                Behavior on border.color { ColorAnimation { duration: 250 } }
            }

            Text {
                anchors.centerIn: parent
                text: "Wallpaper Engine"
                font.pixelSize: 20
                font.bold: root.currentTab === 1
                color: root.currentTab === 1 ? "white" : "#A0FFFFFF"
                Behavior on color { ColorAnimation { duration: 250 } }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.currentTab = 1
                // Fix the "Ghost Click": Make the clickable area visually identical to the slanted box
                transform: Matrix4x4 {
                    property real s: root.skewFactor
                    matrix: Qt.matrix4x4(1, s, 0, 0,
                                         0, 1, 0, 0,
                                         0, 0, 1, 0,
                                         0, 0, 0, 1)
                }
            }
        }
    }

    // ── Models ──────────────────────────────────────────────────────────────
    
    // Model 0: Static Wallpapers (using pre-generated thumbnails)
    FolderListModel {
        id: thumbModel
        folder: root.thumbDir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.avif", "*.gif"]
        showDirs: false
        sortField: FolderListModel.Name

        onStatusChanged: {
            if (status === FolderListModel.Ready && root.currentTab === 0) {
                root.focusCurrentWallpaper()
            }
        }
    }

    // Model 1: Wallpaper Engine (reads directories directly)
    FolderListModel {
        id: weModel
        folder: "file://" + root.weDir
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name
        
        onStatusChanged: {
            if (status === FolderListModel.Ready && root.currentTab === 1) {
                root.focusCurrentWallpaper()
            }
        }
    }

    // ── Horizontal slanted gallery ──────────────────────────────────────────
    ListView {
        id: view
        anchors.top: tabBar.bottom
        anchors.topMargin: 20 
        anchors.bottom: parent.bottom
        
        // INCREASE THIS: Pushes the bottom edge of the list up, giving names space
        anchors.bottomMargin: 80
        
        anchors.left: parent.left
        anchors.right: parent.right

        spacing: 0
        orientation: ListView.Horizontal
        clip: false
        cacheBuffer: 2000
        focus: true

        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: (width / 2) - (root.itemWidth / 2) + 60
        preferredHighlightEnd:   (width / 2) + (root.itemWidth / 2) + 60
        highlightMoveDuration: 300

        // Dynamically switch models
        model: root.currentTab === 0 ? thumbModel : weModel

        delegate: Item {
            id: delegateRoot
            width: root.itemWidth
            height: root.itemHeight
            anchors.verticalCenter: parent.verticalCenter

            readonly property bool isCurrent: ListView.isCurrentItem
            readonly property bool isWE: root.currentTab === 1
            readonly property bool isVideo: isWE ? false : fileName.startsWith("000_")

            // ── Path resolution ──────────────────────────────────────
            
            // Reconstruct static original path from thumbnail
            readonly property string staticOriginalName: {
                if (isWE) return ""
                let n = fileName
                if (n.startsWith("000_")) n = n.substring(4)
                return n.substring(0, n.lastIndexOf("."))
            }
            
            // The file path that will be passed to `switchwall.sh`
            // For WE wallpapers, we pass the absolute path of the directory!
            readonly property string srcPath: isWE ? decodeURIComponent(fileUrl.toString().replace("file://", "")) : (root.srcDir + "/" + staticOriginalName)
            
            // --- SMART FALLBACK LOGIC ---
            property int weExtIndex: 0
            property var weExtensions: ["/preview.jpg", "/preview.gif", "/preview.png"]
            
            readonly property string dynamicImageSource: {
                if (isWE) {
                    return fileUrl.toString() + weExtensions[weExtIndex]
                }
                return fileUrl.toString()
            }

            z: isCurrent ? 10 : 1

            // ── Entry animation per-delegate ──────────────────────────────
            readonly property int ring: Math.abs(index - view.currentIndex)
            
            // Left (and center) comes from top (-1), Right comes from bottom (1)
            readonly property int side: (index <= view.currentIndex) ? -1 : 1
            readonly property real startOffscreenY: side === -1 ? -800 : 800

            property real entrySlideY: startOffscreenY
            property real entryFade: 0

            property bool isUnloading: root.isDismissing && delegateRoot.ring <= root.unloadedRadius
            onIsUnloadingChanged: {
                if (isUnloading) {
                    slideAnim.to = startOffscreenY
                    slideAnim.duration = 350
                    slideDelay.duration = 0
                    slideAnimSeq.restart()

                    fadeAnim.to = 0.0
                    fadeAnim.duration = 200
                    fadeDelay.duration = 0
                    fadeAnimSeq.restart()
                }
            }

            function triggerAnimation() {
                // Reset to off-screen positions instantly
                entrySlideY = startOffscreenY
                entryFade = 0

                // Calculate the stagger
                var delay = delegateRoot.ring * 60

                // Prime and restart slide
                slideAnim.to = 0
                slideAnim.duration = 450
                slideDelay.duration = delay
                slideAnimSeq.restart()

                // Prime and restart fade
                fadeAnim.to = 1.0
                fadeAnim.duration = 300
                fadeDelay.duration = delay + 50
                fadeAnimSeq.restart()
            }

            Connections {
                target: root
                function on_EntryRevealRingChanged() {
                    delegateRoot.triggerAnimation()
                }
            }

            Component.onCompleted: {
                if (root._entryRevealRing > 0) {
                    delegateRoot.triggerAnimation()
                } else {
                    entrySlideY = startOffscreenY
                    entryFade = 0
                }
            }

            SequentialAnimation {
                id: slideAnimSeq
                PauseAnimation { id: slideDelay; duration: 0 }
                NumberAnimation {
                    id: slideAnim
                    target: delegateRoot
                    property: "entrySlideY"
                    to: 0
                    duration: 450
                    easing.type: Easing.OutExpo
                }
            }

            SequentialAnimation {
                id: fadeAnimSeq
                PauseAnimation { id: fadeDelay; duration: 50 }
                NumberAnimation {
                    id: fadeAnim
                    target: delegateRoot
                    property: "entryFade"
                    to: 1.0
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            function pickWallpaper() {
                const modeArg = root.useDarkMode ? "dark" : "light"
                Quickshell.execDetached(["bash", "-c", `~/.config/quickshell/ii/scripts/colors/switchwall.sh '${srcPath}' --mode ${modeArg}`])
                // Since this uses quickshell detached, it doesn't close immediately. Let's animate out!
                root.requestClose()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    view.currentIndex = index
                    delegateRoot.pickWallpaper()
                }
            }

            // ── Slanted card ─────────────────────────────────────────────
            Item {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height

                scale:   delegateRoot.isCurrent ? 1.15 : 0.95
                opacity: (delegateRoot.isCurrent ? 1.0 : 0.6) * delegateRoot.entryFade

                Behavior on scale   { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 500 } }

                // FIX: Explicitly translate X and Y *after* the Matrix skew to force a diagonal slash
                transform: [
                    Matrix4x4 {
                        property real s: root.skewFactor
                        matrix: Qt.matrix4x4(1, s, 0, 0,
                                             0, 1, 0, 0,
                                             0, 0, 1, 0,
                                             0, 0, 0, 1)
                    },
                    Translate { 
                        // Maps the vertical slide perfectly to the slant angle
                        x: delegateRoot.entrySlideY * root.skewFactor 
                        y: delegateRoot.entrySlideY 
                    }
                ]

                // 1. Thin coloured border based on 1x1 blur of the image
                Image {
                    anchors.fill: parent
                    source: delegateRoot.dynamicImageSource
                    sourceSize: Qt.size(1, 1)
                    fillMode: Image.Stretch
                    asynchronous: true
                    
                    // If the .jpg fails, QML throws an error. We catch it and try .gif, then .png!
                    onStatusChanged: {
                        if (status === Image.Error && delegateRoot.isWE) {
                            if (delegateRoot.weExtIndex < 2) {
                                delegateRoot.weExtIndex++
                            }
                        }
                    }
                }

                // Inner content — clip + counter-skew keeps image upright
                Item {
                    anchors.fill: parent
                    anchors.margins: root.borderWidth
                    clip: true

                    Rectangle { anchors.fill: parent; color: "black" }

                    // 2. The actual crisp image (Now supports animated GIFs!)
                    AnimatedImage {
                        anchors.centerIn: parent
                        // A slight offset so the horizontal center aligns better due to skew
                        anchors.horizontalCenterOffset: -50
                        
                        width: parent.width + (parent.height * Math.abs(root.skewFactor)) + 50
                        height: parent.height
                        fillMode: Image.PreserveAspectCrop
                        
                        source: delegateRoot.dynamicImageSource
                        asynchronous: true
                        
                        // Optimization: Only play the GIF if this specific card is selected!
                        playing: delegateRoot.isCurrent 
                        
                        transform: Matrix4x4 {
                            property real s: -root.skewFactor
                            matrix: Qt.matrix4x4(1, s, 0, 0,
                                                 0, 1, 0, 0,
                                                 0, 0, 1, 0,
                                                 0, 0, 0, 1)
                        }
                    }

                    // ▶ Play badge (Visible for standard videos OR all WE items)
                    Rectangle {
                        visible: delegateRoot.isVideo || delegateRoot.isWE
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        width: 32; height: 32
                        radius: 6
                        color: "#80000000"

                        transform: Matrix4x4 {
                            property real s: -root.skewFactor
                            matrix: Qt.matrix4x4(1, s, 0, 0,
                                                 0, 1, 0, 0,
                                                 0, 0, 1, 0,
                                                 0, 0, 0, 1)
                        }

                        Canvas {
                            anchors.fill: parent
                            anchors.margins: 8
                            onPaint: {
                                var ctx = getContext("2d")
                                // If WE, use a WE aesthetic green glow!
                                ctx.fillStyle = delegateRoot.isWE ? "#88FF88" : "#EEFFFFFF"
                                ctx.beginPath()
                                ctx.moveTo(4, 0)
                                ctx.lineTo(14, 8)
                                ctx.lineTo(4, 16)
                                ctx.closePath()
                                ctx.fill()
                            }
                        }
                    }
                }
            }
            
            // Wallpaper Title Label at the bottom (only really needed for WE items)
            Text {
                visible: delegateRoot.isCurrent && delegateRoot.isWE
                // Anchor the TOP of the text to the BOTTOM of the slanted card
                anchors.top: parent.bottom 
                anchors.topMargin: 15     
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Keep it strictly contained to the width of its parent card so it cleanly wraps!
                width: parent.width 
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                
                // Cleanup the folder name to just the title (removes "[WE-ID]")
                text: fileName.replace(/\s*\[WE-\d+\]$/, "")
                font.pixelSize: 20
                font.bold: true
                color: "white"
                style: Text.Outline; styleColor: "black"
            }
        }
    }

    Component.onCompleted: {
        view.forceActiveFocus()
        root.focusCurrentWallpaper()
    }
}
