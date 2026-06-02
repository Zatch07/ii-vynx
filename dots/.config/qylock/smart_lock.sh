#!/usr/bin/env bash

# 1. State Tracking Fix: Use a file lock instead of race-prone pgrep
exec 9>/tmp/smart_lock.lock
if ! flock -n 9; then
    echo "Locker already active. Waiting for it to close..."
    # Wait for the lock to be released
    flock 9
    exit 0
fi

CONFIG_FILE="$HOME/.config/illogical-impulse/config.json"
LAUNCH_ON_STARTUP=$(jq -r '.lock.launchOnStartup // false' "$CONFIG_FILE")
LOCK_THEME=$(jq -r '.lock.lockTheme // "nier"' "$CONFIG_FILE")
export QS_REQUIRE_PASSWORD_POWER=$(jq -r '.lock.security.requirePasswordToPower // false' "$CONFIG_FILE")
export QS_UNLOCK_KEYRING=$(jq -r '.lock.security.unlockKeyring // false' "$CONFIG_FILE")

STARTUP_MODE=false
if [ "$1" == "--startup" ]; then
    STARTUP_MODE=true
fi

# Determine theme to launch
ACTIVE_THEME="$LOCK_THEME"

if [ "$STARTUP_MODE" = true ]; then
    if [ "$LAUNCH_ON_STARTUP" != "true" ] || [ "$LOCK_THEME" == "nier" ]; then
        ACTIVE_THEME="nier"
    fi
fi

echo "Attempting to lock with theme: $ACTIVE_THEME"

if [ "$ACTIVE_THEME" == "hyprlock" ]; then
    echo "Launching Hyprlock..."
    exec 9>&-
    exec hyprlock
elif [ "$ACTIVE_THEME" == "ii-quickshell" ]; then
    echo "Launching ii-quickshell lock natively via Quickshell..."
    quickshell -c ii ipc call lock activate_ii 9>&-
else
    THEME_DIR="$HOME/.config/qylock/themes/nierlock"
    if [ -f "$THEME_DIR/shell.qml" ]; then
        echo "Detected Native Quickshell Theme. Launching natively..."
        quickshell -p "$THEME_DIR/shell.qml" 9>&-
    else
        false # Trigger fallback
    fi
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
