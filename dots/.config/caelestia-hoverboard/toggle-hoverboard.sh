#!/bin/bash
# toggle-hoverboard.sh
# This script spawns the hoverboard dashboard widget.

export CAELESTIA_LIB_DIR="$HOME/.config/caelestia-hoverboard/build/lib"
export QML2_IMPORT_PATH="$HOME/.config/caelestia-hoverboard/build/qml:${QML2_IMPORT_PATH:-}"
export LD_LIBRARY_PATH="$CAELESTIA_LIB_DIR:${LD_LIBRARY_PATH:-}"

ACTION="${1:-toggle}"

if pgrep -f "[q]uickshell.*caelestia-hoverboard/shell.qml" > /dev/null; then
    if [ "$ACTION" = "open" ]; then
        quickshell -p /home/zatch/.config/caelestia-hoverboard/shell.qml ipc call hoverboard open
    elif [ "$ACTION" = "close" ]; then
        quickshell -p /home/zatch/.config/caelestia-hoverboard/shell.qml ipc call hoverboard close
    else
        quickshell -p /home/zatch/.config/caelestia-hoverboard/shell.qml ipc call hoverboard toggle
    fi
else
    if [ "$ACTION" != "close" ]; then
        quickshell -d -p /home/zatch/.config/caelestia-hoverboard/shell.qml
    fi
fi
