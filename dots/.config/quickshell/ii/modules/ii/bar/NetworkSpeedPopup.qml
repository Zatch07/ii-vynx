import qs.modules.common
import qs.modules.common.widgets
import qs.services
import "./cards"
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    popupRadius: Appearance.rounding.large

    // Unit-aware formatting that respects user preferences (mirrors NetworkSpeed.qml)
    readonly property int unitType: Config.options.bar.networkSpeed.unitType

    function formatSpeed(bytesPerSecond) {
        var divisor = (unitType === 0) ? 1024 : 1000;
        var value = bytesPerSecond;
        var suffix = "/s";
        var baseUnit = "B";
        
        if (unitType === 2) {
            value = bytesPerSecond * 8;
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

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        HeroCard {
            id: networkHero
            icon: Network.ethernet ? "lan" : "wifi"
            title: Network.ethernet ? Translation.tr("Ethernet") : Translation.tr("Wi-Fi")
            subtitle: Network.networkName || Translation.tr("Connected")
            
            compactMode: true
            adaptiveWidth: true
            
            // Show signal strength in the pill if wifi
            pillText: !Network.ethernet ? (Network.networkStrength + "%") : ""
            pillIcon: !Network.ethernet ? "signal_wifi_4_bar" : ""
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            InfoPill {
                icon: "download"
                text: Translation.tr("Download: ") + formatSpeed(NetworkUsage.networkDownloadSpeed)
                containerColor: Appearance.colors.colPrimaryContainer
                shapeColor: Appearance.colors.colPrimary
                symbolColor: Appearance.colors.colOnPrimary
                textColor: Appearance.colors.colOnPrimaryContainer
            }

            InfoPill {
                icon: "upload"
                text: Translation.tr("Upload: ") + formatSpeed(NetworkUsage.networkUploadSpeed)
                containerColor: Appearance.colors.colSecondaryContainer
                shapeColor: Appearance.colors.colSecondary
                symbolColor: Appearance.colors.colOnSecondary
                textColor: Appearance.colors.colOnSecondaryContainer
            }

            InfoPill {
                visible: !Config.options.bar.tooltips.compactPopups
                icon: "data_usage"
                text: Translation.tr("Usage: ") + formatTotal(NetworkUsage.networkDownloadTotal + NetworkUsage.networkUploadTotal)
                containerColor: Appearance.colors.colTertiaryContainer
                shapeColor: Appearance.colors.colTertiary
                symbolColor: Appearance.colors.colOnTertiary
                textColor: Appearance.colors.colOnTertiaryContainer
            }
        }
    }
}
