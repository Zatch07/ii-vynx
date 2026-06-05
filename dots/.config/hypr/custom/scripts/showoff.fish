function showoff
    # Run the heavy lifting in a completely detached background process
    fish -c '
        # Get monitor dimensions and save for Lua rules to read safely
        set RES (hyprctl monitors -j | jq -r ".[0].width, .[0].height")
        echo $RES[1] > /tmp/hypr_monitor_dim.txt
        echo $RES[2] >> /tmp/hypr_monitor_dim.txt

        hyprctl reload
        sleep 0.2
        cat ~/showapps.txt | while read -l app
            if test -n "$app"
                setsid kitty -T "showoff_$app" fish -c "$app" >/dev/null 2>&1 &
            end
        end
    ' &
    disown
    
    # Immediately close the current shell (which closes the terminal) 
    # before the new windows even have a chance to steal focus!
    exit
end
