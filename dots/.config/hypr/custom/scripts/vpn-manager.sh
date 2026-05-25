#!/usr/bin/env bash

# Automatically toggle, connect, and retrieve the status of WireGuard connections.
# Ideal for rotating through multiple ProtonVPN or any WireGuard configs smoothly.

case "$1" in
    status)
        # Find the active wireguard connection (if any)
        active_wg=$(nmcli -t -f NAME,TYPE,STATE connection show --active | grep 'wireguard.*:activated$' | head -n 1 | cut -d: -f1)
        
        if [ -n "$active_wg" ]; then
            echo "ON:$active_wg"
            exit 0
        fi

        # Find available wireguard connections
        available_wg=$(nmcli -t -f NAME,TYPE connection show | grep ':wireguard$' | cut -d: -f1)
        if [ -n "$available_wg" ]; then
            echo "OFF:Available"
            exit 0
        else
            echo "NONE:No Configs"
            exit 0
        fi
        ;;
    
    toggle)
        # Check if currently connected
        active_wg=$(nmcli -t -f NAME,TYPE,STATE connection show --active | grep 'wireguard.*:activated$' | head -n 1 | cut -d: -f1)
        
        if [ -n "$active_wg" ]; then
            # We are connected, so turn it off
            nmcli connection down "$active_wg"
        else
            # We are NOT connected. Pick a wireguard profile and turn it on
            # Let's pick a random one from the available list to satisfy "multiple configs in case of loads"
            available_wg=($(nmcli -t -f NAME,TYPE connection show | grep ':wireguard$' | cut -d: -f1))
            
            if [ ${#available_wg[@]} -eq 0 ]; then
                notify-send "Proton VPN" "No WireGuard configurations found in NetworkManager!" -a "Shell" -u critical
                exit 1
            fi
            
            # Select a random config
            random_index=$((RANDOM % ${#available_wg[@]}))
            chosen_wg="${available_wg[$random_index]}"
            
            # Connect
            notify-send "Proton VPN" "Connecting to $chosen_wg..." -a "Shell"
            if nmcli connection up "$chosen_wg"; then
                notify-send "Proton VPN" "Successfully connected to $chosen_wg" -a "Shell"
            else
                notify-send "Proton VPN" "Failed to connect to $chosen_wg" -a "Shell" -u critical
                exit 1
            fi
        fi
        ;;
        
    *)
        echo "Usage: $0 {status|toggle}"
        exit 1
        ;;
esac
