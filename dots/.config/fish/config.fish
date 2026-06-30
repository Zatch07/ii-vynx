# Auto start Hyprland on tty1
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        mkdir -p ~/.cache
        # Clear the terminal screen to hide any boot text before graphics initialize
        clear
        exec start-hyprland > ~/.cache/hyprland.log 2>&1
    end
end

# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    set fish_greeting

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end
    
    # Colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'
    alias settings-custom 'quickshell --path ~/.config/quickshell/ii/custom-settings.qml >/dev/null 2>&1 & disown; echo "custom settings launched"'
    if test "$TERM" != "linux"
        alias ls 'eza --icons'
    end
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end
end

# Bay of Assets - Claude Code Config
set -gx ANTHROPIC_BASE_URL https://api.bayofassets.com/
set -gx ANTHROPIC_AUTH_TOKEN "boa-9dc83464-e55a-4311-88a2-069e63f97686"
set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL claude-haiku-4-5
set -gx ANTHROPIC_DEFAULT_SONNET_MODEL claude-sonnet-4-6-thinking
set -gx ANTHROPIC_DEFAULT_OPUS_MODEL claude-opus-4-6-thinking
