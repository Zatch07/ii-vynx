import QtQuick
import Quickshell

ShellRoot {
    Component.onCompleted: {
        Quickshell.execDetached(["/usr/bin/python3", "/home/zatch/.local/bin/update_hypr_gui.py", "--rounding", "25"])
        Qt.quit()
    }
}
