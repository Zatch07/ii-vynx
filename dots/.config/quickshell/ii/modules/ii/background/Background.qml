pragma ComponentBehavior: Bound

import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.widgetCanvas
import qs.modules.common.functions as CF
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.modules.ii.background.widgets
import qs.modules.ii.background.widgets.clock
import qs.modules.ii.background.widgets.weather

Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: bgRoot

        required property var modelData

        // Hide when fullscreen
        property list<HyprlandWorkspace> workspacesForMonitor: Hyprland.workspaces.values.filter(workspace => workspace.monitor && workspace.monitor.name == monitor.name)
        property var activeWorkspaceWithFullscreen: workspacesForMonitor.filter(workspace => ((workspace.toplevels.values.filter(window => window.wayland?.fullscreen)[0] != undefined) && workspace.active))[0]
        visible: GlobalStates.screenLocked || (!(activeWorkspaceWithFullscreen != undefined)) || !Config?.options.background.hideWhenFullscreen

        // Workspaces
        property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)
        property list<var> relevantWindows: HyprlandData.windowList.filter(win => win.monitor == monitor?.id && win.workspace.id >= 0).sort((a, b) => a.workspace.id - b.workspace.id)
        property int firstWorkspaceId: relevantWindows[0]?.workspace.id || 1
        property int lastWorkspaceId: relevantWindows[relevantWindows.length - 1]?.workspace.id || 10
        property int workspaceChunkSize: Config?.options.bar.workspaces.shown ?? 10
        property int totalWorkspaces: Math.ceil(lastWorkspaceId / workspaceChunkSize) * workspaceChunkSize
        // Wallpaper
        property bool wallpaperIsVideo: Config.options.background.wallpaperPath.endsWith(".mp4") || Config.options.background.wallpaperPath.endsWith(".webm") || Config.options.background.wallpaperPath.endsWith(".mkv") || Config.options.background.wallpaperPath.endsWith(".avi") || Config.options.background.wallpaperPath.endsWith(".mov") || Config.options.background.wallpaperPath.indexOf("[WE-") !== -1
        property string wallpaperPath: wallpaperIsVideo ? Config.options.background.thumbnailPath : Config.options.background.wallpaperPath
        property bool wallpaperSafetyTriggered: {
            const enabled = Config.options.workSafety.enable.wallpaper;
            const sensitiveWallpaper = (CF.StringUtils.stringListContainsSubstring(wallpaperPath.toLowerCase(), Config.options.workSafety.triggerCondition.fileKeywords));
            const sensitiveNetwork = (CF.StringUtils.stringListContainsSubstring(Network.networkName.toLowerCase(), Config.options.workSafety.triggerCondition.networkNameKeywords));
            return enabled && sensitiveWallpaper && sensitiveNetwork;
        }
        readonly property real parallaxRation: 1.1
        readonly property real additionalScaleFactor: Config.options.background.parallax.workspaceZoom
        property real effectiveWallpaperScale: 1 // Some reasonable init value, to be updated
        property int wallpaperWidth: modelData.width // Some reasonable init value, to be updated
        property int wallpaperHeight: modelData.height // Some reasonable init value, to be updated
        property real scaledWallpaperWidth: wallpaperWidth * effectiveWallpaperScale
        property real scaledWallpaperHeight: wallpaperHeight * effectiveWallpaperScale
        property real parallaxTotalPixelsX: Math.max(0, scaledWallpaperWidth - screen.width)
        property real parallaxTotalPixelsY: Math.max(0, scaledWallpaperHeight - screen.height)
        readonly property bool verticalParallax: (Config.options.background.parallax.autoVertical && wallpaperHeight > wallpaperWidth) || Config.options.background.parallax.vertical
        // Colors
        property bool shouldBlur: (GlobalStates.screenLocked && Config.options.lock.blur.enable)
        property color dominantColor: Appearance.colors.colPrimary // Default, to be changed
        property bool dominantColorIsDark: dominantColor.hslLightness < 0.5
        property color colText: {
            if (wallpaperSafetyTriggered)
                return CF.ColorUtils.mix(Appearance.colors.colOnLayer0, Appearance.colors.colPrimary, 0.75);
            return (GlobalStates.screenLocked && shouldBlur) ? Appearance.colors.colOnLayer0 : CF.ColorUtils.colorWithLightness(Appearance.colors.colPrimary, (dominantColorIsDark ? 0.8 : 0.12));
        }
        Behavior on colText {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        // Layer props
        screen: modelData
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: (GlobalStates.screenLocked && !scaleAnim.running) ? WlrLayer.Overlay : WlrLayer.Bottom
        // WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell:background"
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: {
            if (!bgRoot.wallpaperSafetyTriggered || bgRoot.wallpaperIsVideo)
                return "transparent";
            return CF.ColorUtils.mix(Appearance.colors.colLayer0, Appearance.colors.colPrimary, 0.75);
        }
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        onWallpaperPathChanged: {
            bgRoot.updateZoomScale();
            // Clock position gets updated after zoom scale is updated
        }

        // Wallpaper zoom scale
        function updateZoomScale() {
            getWallpaperSizeProc.path = bgRoot.wallpaperPath;
            getWallpaperSizeProc.running = true;
        }
        Process {
            id: getWallpaperSizeProc
            property string path: bgRoot.wallpaperPath
            command: ["magick", "identify", "-format", "%w %h", path]
            stdout: StdioCollector {
                id: wallpaperSizeOutputCollector
                onStreamFinished: {
                    const output = wallpaperSizeOutputCollector.text;
                    const [width, height] = output.split(" ").map(Number);
                    const [screenWidth, screenHeight] = [bgRoot.screen.width, bgRoot.screen.height];
                    bgRoot.wallpaperWidth = width;
                    bgRoot.wallpaperHeight = height;

                    // Perfect image; scale = 1
                    // Small picture; scale > 1; will zoom in the picture
                    // Big picture; scale < 1; will zoom out the picture
                    // Choose max number so every side will fit
                    const minSuitableScale = Math.max(screenWidth / width, screenHeight / height);
                    bgRoot.effectiveWallpaperScale = minSuitableScale * bgRoot.additionalScaleFactor * bgRoot.parallaxRation;
                }
            }
        }

        property bool mediaModeOpen: mediaModeLoader.active && MprisController.activePlayer
        onMediaModeOpenChanged: {
            if (!mediaModeOpen && Config.options.appearance.palette.type.startsWith("scheme")) {
                Wallpapers.apply(Config.options.background.wallpaperPath)
                LyricsService.shellColorChanged = false
            }
        }

        property var _extensionBgWidgetEntries: []
        property var _pendingWidgetSaves: ({})

        Timer {
            id: bgWidgetSaveTimer
            interval: 300
            repeat: false
            onTriggered: {
                for (let key in bgRoot._pendingWidgetSaves) {
                    let p = bgRoot._pendingWidgetSaves[key]
                    ExtensionManager.saveExtensionWidgetConfig(p.extId, p.wid, p.config)
                }
                bgRoot._pendingWidgetSaves = {}
            }
        }

        function refreshExtensionBgWidgets() {
            // Destroy all existing extension widget objects
            for (let i = 0; i < _extensionBgWidgetEntries.length; i++) {
                let entry = _extensionBgWidgetEntries[i]
                if (entry) {
                    if (entry.cfg) entry.cfg.destroy()
                    if (entry.widget) entry.widget.destroy()
                }
            }
            _extensionBgWidgetEntries = []

            let list = ExtensionManager.getContributionPoint("backgroundWidgets")

            for (let wi = 0; wi < list.length; wi++) {
                let entry = list[wi]
                let fullPath = entry.fullPath
                let extId = entry.extensionId
                let wid = entry.identifier
                let x = entry.x
                let y = entry.y
                let strat = entry.placementStrategy || "free"

                let comp = ExtensionManager.loadExtensionQmlComponent(fullPath)

                let createWidget = (comp, entry, fullPath, extId, wid, x, y, strat) => {
                    let savedWidgetConfig = ExtensionManager.getExtensionWidgetConfig(extId, wid)
                    let savedX = savedWidgetConfig ? savedWidgetConfig.x : x
                    let savedY = savedWidgetConfig ? savedWidgetConfig.y : y
                    let qml = 'import QtQml; QtObject { property bool enable: true; property real x: ' + savedX + '; property real y: ' + savedY + '; property string placementStrategy: "' + strat + '" }'
                    let cfg = Qt.createQmlObject(qml,bgRoot)

                    let onPosChanged = () => {
                        bgRoot._pendingWidgetSaves[extId + "/" + wid] = {
                            extId: extId,
                            wid: wid,
                            config: { enable: cfg.enable, x: cfg.x, y: cfg.y }
                        }
                        bgWidgetSaveTimer.restart()
                    }
                    cfg.xChanged.connect(onPosChanged)
                    cfg.yChanged.connect(onPosChanged)

                    let widget = comp.createObject(widgetCanvas, {
                        configEntry: cfg,
                        screenWidth: bgRoot.screen.width,
                        screenHeight: bgRoot.screen.height,
                        scaledScreenWidth: bgRoot.screen.width / bgRoot.effectiveWallpaperScale,
                        scaledScreenHeight: bgRoot.screen.height / bgRoot.effectiveWallpaperScale,
                        wallpaperScale: bgRoot.effectiveWallpaperScale
                    })

                    if (widget && extId) {
                        if ("extensionId" in widget) {
                            widget.extensionId = extId
                        } else {
                            Object.defineProperty(widget, "extensionId", {
                                value: extId,
                                writable: true,
                                configurable: true,
                                enumerable: true
                            })
                        }
                        let entries = _extensionBgWidgetEntries.slice()
                        entries.push({ widget: widget, cfg: cfg })
                        _extensionBgWidgetEntries = entries
                    }
                }

                if (comp.status === Component.Ready) {
                    createWidget(comp, entry, fullPath, extId, wid, x, y, strat)
                } else if (comp.status === Component.Error) {
                    console.warn("Background: failed to load extension widget component for", extId, wid, ":", comp.errorString())
                } else {
                    comp.statusChanged.connect(() => {
                        if (comp.status === Component.Ready) {
                            createWidget(comp, entry, fullPath, extId, wid, x, y, strat)
                        } else if (comp.status === Component.Error) {
                            console.warn("Background: async component error for", extId, wid, ":", comp.errorString())
                        }
                    })
                }
            }

        }

        Component.onCompleted: {
            refreshExtensionBgWidgets()
            if (!mediaModeOpen && Config.options.appearance.palette.type.startsWith("scheme")) {
                Wallpapers.apply(Config.options.background.wallpaperPath)
            }
        }

        Connections {
            target: ExtensionManager
            function onRefreshExtensions() { refreshExtensionBgWidgets() }
        }
        Item {
            anchors.fill: parent

            // Wallpaper
            TransitionImage {
                id: wallpaper
                visible: !blurLoader.active
                opacity: bgRoot.wallpaperIsVideo ? 0 : 1
                cache: false
                smooth: false

                property int workspaceIndex: (bgRoot.monitor.activeWorkspace?.id ?? 1) - 1
                property real middleFraction: 0.5
                property real fraction: {
                    // 0 - start of the picture
                    // 1 - end of the picture
                    if (bgRoot.totalWorkspaces <= 1) {
                        return middleFraction;
                    }
                    return Math.max(0, Math.min(1, workspaceIndex / (bgRoot.totalWorkspaces - 1)));
                }

                property real usedFractionX: {
                    let usedFraction = middleFraction;
                    if (Config.options.background.parallax.enableWorkspace && !bgRoot.verticalParallax) {
                        usedFraction = fraction;
                    }
                    if (Config.options.background.parallax.enableSidebar) {
                        let sidebarFraction = bgRoot.parallaxRation / bgRoot.workspaceChunkSize / 2;
                        usedFraction += (sidebarFraction * GlobalStates.sidebarRightOpen - sidebarFraction * GlobalStates.sidebarLeftOpen);
                    }
                    return Math.max(0, Math.min(1, usedFraction));
                }
                property real usedFractionY: {
                    let usedFraction = middleFraction;
                    if (Config.options.background.parallax.enableWorkspace && bgRoot.verticalParallax) {
                        usedFraction = fraction;
                    }
                    return Math.max(0, Math.min(1, usedFraction));
                }

                x: {
                    if (bgRoot.screen.width > bgRoot.scaledWallpaperWidth) {
                        // Center the picture
                        return (bgRoot.screen.width - bgRoot.scaledWallpaperWidth) / 2;
                    }
                    return - bgRoot.parallaxTotalPixelsX * usedFractionX;
                }
                y: {
                    if (bgRoot.screen.height > bgRoot.scaledWallpaperHeight) {
                        // Center the picture
                        return (bgRoot.screen.height - bgRoot.scaledWallpaperHeight) / 2;
                    }
                    return - bgRoot.parallaxTotalPixelsY * usedFractionY;
                }

                imageSource: bgRoot.wallpaperSafetyTriggered ? "" : bgRoot.wallpaperPath
                animated: !bgRoot.wallpaperIsVideo
                fillMode: Image.PreserveAspectCrop
                Behavior on x {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on y {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutCubic
                    }
                }

                width: bgRoot.scaledWallpaperWidth
                height: bgRoot.scaledWallpaperHeight
            }

            Loader {
                id: blurLoader
                active: Config.options.lock.blur.enable && (GlobalStates.screenLocked || scaleAnim.running)
                anchors.fill: wallpaper
                scale: GlobalStates.screenLocked ? Config.options.lock.blur.extraZoom : 1
                Behavior on scale {
                    NumberAnimation {
                        id: scaleAnim
                        duration: 400
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.animationCurves.expressiveDefaultSpatial
                    }
                }
                sourceComponent: GaussianBlur {
                    source: wallpaper
                    radius: GlobalStates.screenLocked ? Config.options.lock.blur.radius : 0
                    samples: radius * 2 + 1

                    Rectangle {
                        opacity: GlobalStates.screenLocked ? 1 : 0
                        anchors.fill: parent
                        color: CF.ColorUtils.transparentize(Appearance.colors.colLayer0, 0.7)
                    }
                }
            }

            FadeLoader {
                shown: GlobalStates.mediaModeOpen
                anchors.fill: parent
                sourceComponent: MediaMode {}
            }

            WidgetCanvas {
                id: widgetCanvas
                width: parent.width
                height: parent.height
                readonly property real parallaxFactor: {
                    var f = Config.options.background.parallax.widgetsFactor;
                    return f / Config.options.background.parallax.workspaceZoom;
                }
                readonly property real baseWallpaperOffsetX: (bgRoot.screen.width - bgRoot.scaledWallpaperWidth) / 2
                readonly property real baseWallpaperOffsetY: (bgRoot.screen.height - bgRoot.scaledWallpaperHeight) / 2
                readonly property real wallpaperTotalOffsetX: wallpaper.x - baseWallpaperOffsetX
                readonly property real wallpaperTotalOffsetY: wallpaper.y - baseWallpaperOffsetY
                readonly property bool locked: GlobalStates.screenLocked
                x: wallpaperTotalOffsetX * parallaxFactor * !locked
                y: wallpaperTotalOffsetY * parallaxFactor * !locked

                transitions: Transition {
                    PropertyAnimation {
                        properties: "width,height"
                        duration: Appearance.animation.elementMove.duration
                        easing.type: Appearance.animation.elementMove.type
                        easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
                    }
                    AnchorAnimation {
                        duration: Appearance.animation.elementMove.duration
                        easing.type: Appearance.animation.elementMove.type
                        easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
                    }
                }

                FadeLoader {
                    shown: Config.options.background.widgets.weather.enable
                    sourceComponent: WeatherWidget {
                        screenWidth: bgRoot.screen.width
                        screenHeight: bgRoot.screen.height
                        scaledScreenWidth: bgRoot.screen.width
                        scaledScreenHeight: bgRoot.screen.height
                        wallpaperScale: 1
                    }
                }

                FadeLoader {
                    shown: Config.options.background.widgets.clock.enable
                    sourceComponent: ClockWidget {
                        screenWidth: bgRoot.screen.width
                        screenHeight: bgRoot.screen.height
                        scaledScreenWidth: bgRoot.screen.width
                        scaledScreenHeight: bgRoot.screen.height
                        wallpaperScale: 1
                        wallpaperSafetyTriggered: bgRoot.wallpaperSafetyTriggered
                    }
                }
            }
        }
    }
}
