#!/usr/bin/env bash

# 1. State Tracking Fix: Use a file lock instead of race-prone pgrep
exec 9>/tmp/smart_lock.lock
if ! flock -n 9; then
    echo "Locker already active. Waiting for it to close..."
    # Wait for the lock to be released
    flock 9
    exit 0
fi

THEME_FILE="$HOME/.config/qylock/theme"
THEME=$(cat "$THEME_FILE" 2>/dev/null || echo "nier-automata")
THEME_DIR="$HOME/.config/qylock/themes/$THEME"

echo "Attempting to lock with theme: $THEME"

if [ -f "$THEME_DIR/shell.qml" ]; then
    echo "Detected Native Quickshell Theme. Launching natively..."
    quickshell -p "$THEME_DIR/shell.qml" 9>&-
else
    false # Trigger fallback
fi

# 3. Direct Fallback to Hyprlock
EXIT_CODE=$?
# If quickshell is killed smoothly by hypridle unlock (143) it's not a crash.
if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 143 ]; then
    # Double check the session is actually still locked before throwing up hyprlock
    if loginctl show-session $XDG_SESSION_ID -p LockedHint --value 2>/dev/null | grep -q "yes"; then
        echo "Qylock crashed with code $EXIT_CODE. Forcing Hyprlock as fallback."
        exec 9>&-; exec hyprlock
    fi
fi
