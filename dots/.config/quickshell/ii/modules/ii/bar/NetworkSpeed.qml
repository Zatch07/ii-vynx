import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: networkLayout.implicitWidth + 6
    implicitHeight: Appearance.sizes.barHeight

    readonly property int displayMode: Config.options.bar.networkSpeed.displayMode
    readonly property bool showIcons: Config.options.bar.networkSpeed.showIcons
    readonly property int unitType: Config.options.bar.networkSpeed.unitType
    readonly property int iconPosition: Config.options.bar.networkSpeed.iconPosition

    // Shared formatting function for speed values (used by both bar and popup)
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

    // Shared formatting function for total byte counts
    function formatTotal(bytes) {
        var divisor = (unitType === 0) ? 1024 : 1000;
        var value = bytes;
        var baseUnit = "B";

        if (unitType === 2) {
            value = bytes * 8;
            baseUnit = "b";
        }

        if (value < divisor * divisor) {
            var prefix = (unitType === 0) ? "Ki" : (unitType === 1 ? "K" : "k");
            return (value / divisor).toFixed(1) + " " + prefix + baseUnit;
        } else if (value < divisor * divisor * divisor) {
            var prefix = (unitType === 0) ? "Mi" : "M";
            return (value / (divisor * divisor)).toFixed(1) + " " + prefix + baseUnit;
        } else {
            var prefix = (unitType === 0) ? "Gi" : "G";
            return (value / (divisor * divisor * divisor)).toFixed(1) + " " + prefix + baseUnit;
        }
    }

    // DRY helper: wraps a speed string with the appropriate icon based on settings
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
        case 3: return ""; // Handled separately
        default: return formatSpeed(totalSpeed);
        }
    }

    RowLayout {
        id: networkLayout
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6

        // Single line display (modes 0, 1, 2)
        Item {
            id: singleLineContainer
            visible: displayMode !== 3
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: singleLineText.implicitWidth
            implicitHeight: singleLineText.implicitHeight
            StyledText {
                id: singleLineText
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
                text: getDisplayText()
            }
        }

        // Side by side display (mode 3)
        RowLayout {
            visible: displayMode === 3
            spacing: 4

            Item {
                implicitWidth: downloadText.implicitWidth
                implicitHeight: downloadText.implicitHeight
                Layout.alignment: Qt.AlignVCenter
                StyledText {
                    id: downloadText
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 1
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                    text: applyIcon(formatSpeed(NetworkUsage.networkDownloadSpeed), "↓")
                }
            }

            Item {
                implicitWidth: uploadText.implicitWidth
                implicitHeight: uploadText.implicitHeight
                Layout.alignment: Qt.AlignVCenter
                StyledText {
                    id: uploadText
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 1
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                    text: applyIcon(formatSpeed(NetworkUsage.networkUploadSpeed), "↑")
                }
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
                Config.options.bar.networkSpeed.displayMode = (Config.options.bar.networkSpeed.displayMode + 1) % 4;
            } else if (mouse.button === Qt.LeftButton) {
                if (!Config.options.bar.tooltips.clickToShow) {
                    Config.options.bar.networkSpeed.displayMode = (Config.options.bar.networkSpeed.displayMode + 1) % 4;
                }
            }
        }
    }

    NetworkSpeedPopup {
        hoverTarget: mouseArea
    }
}
