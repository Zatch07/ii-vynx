import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool vertical: false
    readonly property bool autoHide: Config.options.bar.networkSpeed.autoHide ?? true
    readonly property int threshold: {
        if (unitType === 0) return 1024;       // 1 KiB = 1024 Bytes
        if (unitType === 1) return 1000;       // 1 KB = 1000 Bytes
        if (unitType === 2) return 125;        // 1 Kb = 1000 bits = 125 Bytes
        return 1024;
    }
    readonly property bool hasActivity: {
        if (displayMode === 1) {
            return NetworkUsage.networkDownloadSpeed >= threshold;
        } else if (displayMode === 2) {
            return NetworkUsage.networkUploadSpeed >= threshold;
        } else if (displayMode === 3) {
            return NetworkUsage.networkDownloadSpeed >= threshold || NetworkUsage.networkUploadSpeed >= threshold;
        } else {
            return (NetworkUsage.networkDownloadSpeed + NetworkUsage.networkUploadSpeed) >= threshold;
        }
    }
    property bool showWidget: true

    visible: autoHide ? showWidget : true
    implicitWidth: visible ? (vertical ? Appearance.sizes.verticalBarWidth : networkLayout.implicitWidth + 6) : 0
    implicitHeight: visible ? (vertical ? (displayMode === 5 ? singleLineText.implicitWidth + 6 : networkLayout.implicitHeight + 6) : Appearance.sizes.barHeight) : 0

    // Auto-hide delay timer (10 seconds grace period to prevent layour flickering)
    Timer {
        id: hideTimer
        interval: 10000
        running: autoHide && !hasActivity
        repeat: false
        onTriggered: {
            showWidget = false;
        }
    }

    function updateVisibility() {
        try {
            if (typeof rootItem !== "undefined") {
                rootItem.visible = (!autoHide || showWidget);
            } else {
                root.visible = (!autoHide || showWidget);
            }
        } catch (e) {
            root.visible = (!autoHide || showWidget);
        }
    }

    onShowWidgetChanged: updateVisibility()

    onHasActivityChanged: {
        if (hasActivity) {
            hideTimer.stop();
            showWidget = true;
        }
        updateVisibility();
    }

    onAutoHideChanged: {
        if (!autoHide) {
            hideTimer.stop();
            showWidget = true;
        }
        updateVisibility();
    }

    readonly property int displayMode: Config.options.bar.networkSpeed.displayMode
    readonly property bool showIcons: Config.options.bar.networkSpeed.showIcons
    readonly property int unitType: Config.options.bar.networkSpeed.unitType
    readonly property int iconPosition: Config.options.bar.networkSpeed.iconPosition

    onVerticalChanged: {
        if (vertical) {
            if (Config.options.bar.networkSpeed.displayMode < 4) {
                Config.options.bar.networkSpeed.displayMode = 5;
            }
        } else {
            if (Config.options.bar.networkSpeed.displayMode === 5) {
                Config.options.bar.networkSpeed.displayMode = 0;
            }
        }
    }

    Component.onCompleted: {
        NetworkUsage.activeInstances++;
        if (vertical) {
            if (Config.options.bar.networkSpeed.displayMode < 4) {
                Config.options.bar.networkSpeed.displayMode = 5;
            }
        } else {
            if (Config.options.bar.networkSpeed.displayMode === 5) {
                Config.options.bar.networkSpeed.displayMode = 0;
            }
        }
        updateVisibility();
    }
    Component.onDestruction: NetworkUsage.activeInstances--

    // Shared formatting function for speed values
    function formatSpeed(bytesPerSecond) {
        var divisor = (unitType === 0) ? 1024 : 1000;
        var value = bytesPerSecond;
        var suffix = "/s";
        var baseUnit = "B";
        
        if (unitType === 2) {
            value = bytesPerSecond * 8; // convert to bits
            baseUnit = "b";
        }

        if (value < divisor) {
            return value.toFixed(0) + " " + baseUnit + suffix;
        } else if (value < divisor * divisor) {
            var prefix = (unitType === 0) ? "Ki" : (unitType === 1 ? "K" : "k");
            return (value / divisor).toFixed(1) + " " + prefix + baseUnit + suffix;
        } else if (value < divisor * divisor * divisor) {
            var prefix = (unitType === 0) ? "Mi" : "M";
            return (value / (divisor * divisor)).toFixed(1) + " " + prefix + baseUnit + suffix;
        } else {
            var prefix = (unitType === 0) ? "Gi" : "G";
            return (value / (divisor * divisor * divisor)).toFixed(1) + " " + prefix + baseUnit + suffix;
        }
    }

    // DRY helper: wraps a speed string with the appropriate icon
    function applyIcon(speedText, iconSymbol) {
        if (!showIcons) return speedText;
        return iconPosition === 0 ? iconSymbol + " " + speedText : speedText + " " + iconSymbol;
    }

    function getDisplayText() {
        var downloadSpeed = NetworkUsage.networkDownloadSpeed;
        var uploadSpeed = NetworkUsage.networkUploadSpeed;
        var totalSpeed = downloadSpeed + uploadSpeed;

        switch (displayMode) {
        case 0: return applyIcon(formatSpeed(totalSpeed), "↓↑");
        case 1: return applyIcon(formatSpeed(downloadSpeed), "↓");
        case 2: return applyIcon(formatSpeed(uploadSpeed), "↑");
        case 3: return ""; // Handled by separate layout
        case 4: return "↓↑"; 
        case 5: return applyIcon(formatSpeed(totalSpeed), "↓↑");
        default: return formatSpeed(totalSpeed);
        }
    }

    RowLayout {
        id: networkLayout
        anchors.centerIn: parent
        spacing: 6

        // Modes 0, 1, 2, 4, 5 (Single Line/Rotated/Icon Only)
        Item {
            visible: [0, 1, 2, 4, 5].includes(displayMode)
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: displayMode === 5 && root.vertical ? singleLineText.implicitHeight : singleLineText.implicitWidth
            implicitHeight: displayMode === 5 && root.vertical ? singleLineText.implicitWidth : singleLineText.implicitHeight
            StyledText {
                id: singleLineText
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
                text: getDisplayText()
                rotation: (displayMode === 5 && root.vertical) ? 90 : 0
            }
        }

        // Mode 3 (Side by Side)
        GridLayout {
            visible: displayMode === 3
            columns: root.vertical ? 1 : 2
            rowSpacing: 4
            columnSpacing: 4

            StyledText {
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
                text: applyIcon(formatSpeed(NetworkUsage.networkDownloadSpeed), "↓")
                rotation: root.vertical ? 90 : 0
            }
            StyledText {
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
                text: applyIcon(formatSpeed(NetworkUsage.networkUploadSpeed), "↑")
                rotation: root.vertical ? 90 : 0
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: !Config.options.bar.tooltips.clickToShow
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                if (displayMode === 5) return; // Disable right-click when rotated

                let nextMode = (displayMode + 1) % 6;
                
                if (root.vertical) {
                    // Skip horizontal-only modes
                    if (nextMode < 4) {
                        nextMode = 4;
                    }
                } else {
                    // Skip vertical-only mode
                    if (nextMode === 5) {
                        nextMode = 0;
                    }
                }
                
                Config.options.bar.networkSpeed.displayMode = nextMode;
            }
        }
    }

    NetworkSpeedPopup {
        hoverTarget: mouseArea
    }
}
