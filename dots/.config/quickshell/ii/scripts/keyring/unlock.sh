#!/usr/bin/env bash
# Based on https://unix.stackexchange.com/a/602935

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Skip if already unlocked
if "${SCRIPT_DIR}/is_unlocked.sh"; then
    exit 1
fi

# Prompt for password if not provided
if [[ -z "${UNLOCK_PASSWORD}" ]]; then
    echo -n 'Login password: ' >&2
    read -s UNLOCK_PASSWORD || return
fi

# Unlock
killall --wait -q -u "$(whoami)" gnome-keyring-daemon
sleep 0.2

rm -rf /run/user/$(id -u)/keyring

eval $(echo -n "${UNLOCK_PASSWORD}" \
           | gnome-keyring-daemon --daemonize --login \
           | sed -e 's/^/export /')
unset UNLOCK_PASSWORD

if [ -n "$SSH_AUTH_SOCK" ]; then
    dbus-update-activation-environment --systemd SSH_AUTH_SOCK
fi

echo '' >&2
