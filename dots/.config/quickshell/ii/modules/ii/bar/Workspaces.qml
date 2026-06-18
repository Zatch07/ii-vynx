import QtQuick
import qs.modules.common

Loader {
    id: root
    property bool vertical: false

    source: {
        const theme = Config.options.bar.workspaces.theme;
        if (theme === "pacman") return "WorkspacesPacman.qml";
        if (theme === "pill") return "WorkspacesPill.qml";
        if (theme === "jackpot") return "WorkspacesJackpot.qml";
        return "WorkspacesStandard.qml";
    }

    onLoaded: {
        if (item) {
            item.vertical = Qt.binding(() => root.vertical)
        }
    }
}
