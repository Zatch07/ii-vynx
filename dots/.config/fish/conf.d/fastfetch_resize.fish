# Disable fastfetch resize redraw if user runs any other command
function _fastfetch_preexec --on-event fish_preexec
    set -g _fastfetch_visible 0
end

# Redraw fastfetch on window resize if it is the current screen content
function _fastfetch_resize --on-signal WINCH
    if test "$_fastfetch_visible" = "1"
        # Run the fastfetch wrapper to redraw based on new size
        fastfetch
        # Ensure the prompt is properly redrawn at the bottom
        commandline -f repaint
    else
        # If fastfetch is not visible, just ensure any leftover kitty images are cleared if it gets too small
        set -l term_cols (tput cols)
        set -l term_lines (tput lines)
        if test "$term_cols" -lt 75; or test "$term_lines" -lt 20
            kitty +kitten icat --clear 2>/dev/null
        end
    end
end
