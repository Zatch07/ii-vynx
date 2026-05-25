#!/usr/bin/env bash
# qylock/nierlock → GNOME Keyring unlock bridge.
# Called automatically by qylock after PAM verifies your password.
# Uses the official ii-vynx unlock method (unix.stackexchange.com/a/602935).
# $UNLOCK_PASSWORD is passed in via qylock's LockContext.qml execDetached env.

# 1. Skip if already unlocked (uses busctl, same as the ii-vynx is_unlocked.sh)
locked_state=$(busctl --user get-property org.freedesktop.secrets \
    /org/freedesktop/secrets/collection/login \
    org.freedesktop.Secret.Collection Locked 2>/dev/null)

if [[ "${locked_state}" == "b false" ]]; then
    echo "[qylock/unlock] Keyring already unlocked, skipping." >&2
    exit 0
fi

# 2. No password supplied — nothing we can do
if [[ -z "${UNLOCK_PASSWORD}" ]]; then
    echo "[qylock/unlock] No password provided by qylock." >&2
    exit 1
fi

# 3. Kill any existing locked daemon and restart it fully unlocked
#    (this is the exact method used in the official ii-vynx unlock.sh)
killall -q -u "$(whoami)" gnome-keyring-daemon

eval $(echo -n "${UNLOCK_PASSWORD}" \
    | gnome-keyring-daemon --daemonize --login \
    | sed -e 's/^/export /')

unset UNLOCK_PASSWORD

echo "[qylock/unlock] Keyring unlocked successfully." >&2
