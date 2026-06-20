# ii-vynx setup

A comprehensive dotfiles setup script for Hyprland and Quickshell, built on top of illogical-impulse.

## Installation Steps (Fresh System)

If you are installing these dotfiles on a fresh system, the `setup-ii-vynx.sh` script is designed to handle the bootstrapping process from start to finish.

### 1. Prerequisites
Before running the setup, ensure your system has `git` installed so you can clone the repository. The script will automatically install `yay` (an AUR helper) and other base development tools for you if they are missing.

```bash
sudo pacman -S --needed git
```

### 2. Run the Setup
Navigate to the cloned repository and execute the main setup script:

```bash
cd ii-zatch # or whatever you named the cloned directory
./setup-ii-vynx.sh
```

### 3. Follow the Prompts
Because it's a fresh system, the script will automatically detect that the base configuration (`~/.config/illogical-impulse`) is missing and will prompt you to install it:

1. **"Original dots are not installed! Do you want to install them?"** 
   - Type `y` and press **Enter**.
2. **"Enter the subcommand:"** 
   - Type `install` and press **Enter**.
   - *This tells the base `setup` script to run through its full pipeline (installing all core dependencies, setting up system services, and copying the base configs).*

### 4. Let it Finish
Once the base `install` step finishes, `setup-ii-vynx.sh` will seamlessly resume where it left off. It will automatically:
- Apply the specific Vynx Quickshell themes and Hyprland overrides.
- Copy over all your custom configurations (`dots/.config`, `dots/.local`, and `dots-extra` like emacs, fcitx5, and swaylock).
- Trigger the custom app installer to download and install `discord-canary`, `vencord-hook`, `vencord-installer`, `ferdium`, `antigravity-ide`, `spotify-launcher`, and `spicetify`, skipping any that are already present.

Once it completes, simply restart Hyprland or Quickshell (or reboot your system), and everything will be exactly how it is on your current machine!
