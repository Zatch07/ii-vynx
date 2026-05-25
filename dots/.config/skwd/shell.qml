// Minimal skwd shell — only the Alt+Tab window switcher + IPC listener.
// All other components (bar, launcher, lockscreen, etc.) are disabled.
import Quickshell
import Quickshell.Io
import QtQuick
import "qml"
import "qml/switcher"

ShellRoot {
  id: root

  // IPC command FIFO listener
  // Reads from $XDG_RUNTIME_DIR/skwd/cmd
  // Supports: switcherOpen, switcherNext, switcherPrev, switcherConfirm, switcherCancel, switcherClose
  Process {
    id: ipcListener
    running: true
    command: [Config.scriptsDir + "/bash/ipc-listener"]
    onExited: ipcRestartTimer.start()
    stdout: SplitParser {
      onRead: message => {
        var cmd = message.trim()
        if (cmd === "switcherOpen") {
          if (root.switcherInstance) root.switcherInstance.open()
        } else if (cmd === "switcherNext") {
          if (root.switcherInstance) {
            if (!root.switcherInstance.showing) {
              root.switcherInstance.open()
            } else {
              root.switcherInstance.next()
            }
          }
        } else if (cmd === "switcherPrev") {
          if (root.switcherInstance) {
            if (!root.switcherInstance.showing) {
              root.switcherInstance.open()
            } else {
              root.switcherInstance.prev()
            }
          }
        } else if (cmd === "switcherConfirm") {
          if (root.switcherInstance) root.switcherInstance.confirm()
        } else if (cmd === "switcherCancel") {
          if (root.switcherInstance) root.switcherInstance.cancel()
        } else if (cmd === "switcherClose") {
          if (root.switcherInstance) root.switcherInstance.closeSelected()
        }
      }
    }
  }

  Timer {
    id: ipcRestartTimer
    interval: 1000
    onTriggered: ipcListener.running = true
  }

  // Color theme (loaded from matugen-generated palette in ~/.cache/skwd/colors.json)
  Colors {
    id: colors
  }

  // Window switcher component
  Loader {
    id: switcherLoader
    active: Config.windowSwitcherEnabled
    source: "qml/switcher/WindowSwitcher.qml"
    onLoaded: item.colors = Qt.binding(() => colors)
  }

  property var switcherInstance: switcherLoader.item ?? null
}
