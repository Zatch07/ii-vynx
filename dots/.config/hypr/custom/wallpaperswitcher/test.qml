import Quickshell
import "./qs/services"
ShellRoot {
    Component.onCompleted: {
        console.log("pictures:", Directories.pictures);
        Quickshell.exit(0);
    }
}
