function fastfetch --description 'Wrapper around fastfetch to handle resizing and alignment'
    # Always wipe slate clean to force printing at the exact top-left
    printf '\033[2J\033[3J\033[1;1H'

    set -l term_cols (tput cols)
    set -l term_lines (tput lines)

    # Fastfetch output is roughly 20 lines high and 75 columns wide
    if test "$term_cols" -ge 75; and test "$term_lines" -ge 20
        command fastfetch $argv
    else
        # Small screen: we already wiped the screen above, so just do nothing
        # This completely drops the gif and fastfetch, leaving a clean slate!
        # Clear kitty images specifically just in case they persist
        kitty +kitten icat --clear 2>/dev/null
    end
    
    # Mark that fastfetch is currently on the screen for the resize hook
    set -g _fastfetch_visible 1
end
