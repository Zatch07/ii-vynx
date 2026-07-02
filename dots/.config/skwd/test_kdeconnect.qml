import QtQuick
import Quickshell
import qs.services
import qs.modules.common

Item {
    Component.onCompleted: {
        let comp = Qt.createComponent("file:///home/zatch/.config/illogical-impulse/extensions/installed/phone-link/services/KdeConnectService.qml")
        console.warn("Component status:", comp.status);
        if (comp.status === Component.Error) {
            console.warn("Error string:", comp.errorString());
            Quickshell.exit(1);
        } else {
            console.warn("Success!");
            Quickshell.exit(0);
        }
    }
}
