# =====================================================
# Zatch's Custom Fish Setup (Update-Proof)
# =====================================================
# This file is located in ~/.config/fish/conf.d/
# It is excluded from End-4 dotfile updates.

# -----------------------------------------------------
# Path & Environment
# -----------------------------------------------------
fish_add_path -p ~/.local/bin
set -gx EDITOR "code --wait"
set -gx VISUAL "code --wait"

# -----------------------------------------------------
# Dynamic Colors Hook (End-4)
# -----------------------------------------------------
# Ensuring Matugen sequences are loaded early
if status is-interactive
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end
end

# -----------------------------------------------------
# Aliases & Overrides
# -----------------------------------------------------
if status is-interactive
    # We use a hook to ensure these override any defaults set in config.fish
    function on_interactive_startup --on-event fish_prompt
        # Fastfetch on Clear (GIF Randomizer is inside config.jsonc)
        alias clear "printf '\033[2J\033[3J\033[1;1H'; fastfetch"
        alias celar "printf '\033[2J\033[3J\033[1;1H'; fastfetch"
        alias claer "printf '\033[2J\033[3J\033[1;1H'; fastfetch"
        alias c 'clear'
        
        # Remove this function after it runs once
        functions -e on_interactive_startup
    end

    alias ff 'fastfetch'
    alias nf 'fastfetch'
    alias pf 'fastfetch'

    # Navigation & File Management
    alias ls 'eza -a --icons=always'
    alias ll 'eza -al --icons=always'
    alias lt 'eza -a --tree --level=1 --icons=always'
    
    # System
    alias pamcan pacman
    alias q 'qs -c ii'
    alias apps 'tui-apps'
    alias quicklinks 'quick-links'
    alias finder 'finder'
    alias update-grub 'sudo grub-mkconfig -o /boot/grub/grub.cfg'
    
    # Custom Scripts
    # alias lock-change '~/.config/qylock/change_theme.sh'
    alias cursor-change '~/.local/bin/cursor-picker'
    # alias ascii '~/.config/ml4w/scripts/figlet.sh'
    alias whatsapp 'xdg-open "https://web.whatsapp.com"'

    # Git
    alias gs "git status"
    alias ga "git add"
    alias gc "git commit -m"
    alias gp "git push"
    alias gpl "git pull"
    alias gst "git stash"
    alias gsp "git stash; git pull"
    alias gfo "git fetch origin"
    alias gcheck "git checkout"

    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end
end

# -----------------------------------------------------
# Functions
# -----------------------------------------------------

# Yazi: Quit to current working directory
function yazi
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# Code: Silent launch
function code
    command code -r $argv 2>/dev/null
end

# -----------------------------------------------------
# Abbreviations
# -----------------------------------------------------
abbr -a apps tui-apps
abbr -a quicklinks quick-links
abbr -a wa 'xdg-open "https://web.whatsapp.com"'
abbr -a whatsapp 'xdg-open "https://web.whatsapp.com"'
