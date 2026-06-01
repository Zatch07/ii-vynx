import QtQuick
import qs.modules.common

Loader {
    id: root
    property bool vertical: false

    source: Config.options.bar.workspaces.theme === "pacman" ? "WorkspacesPacman.qml" : "WorkspacesStandard.qml"

    onLoaded: {
        if (item) {
            item.vertical = Qt.binding(() => root.vertical)
        }
    }
}
