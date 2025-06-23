# Hyprdots

My Hyprland dotfiles managed with GNU Stow.

## What's included

- **Hyprland** - Window manager
- **Waybar** - Status bar  
- **Wofi** - App launcher
- **Kitty** - Terminal
- **Zsh** - Shell with Oh My Zsh
- **Mako** - Notifications
- **Ranger** - File manager
- **Neovim** - Text editor
- **GTK themes** - System theming
- **System scripts** - Battery monitoring, wifi management

## Installation

1. **Install dependencies:**
   ```bash
   sudo pacman -S hyprland waybar wofi kitty zsh mako ranger neovim stow
   ```

2. **Clone this repo:**
   ```bash
   git clone https://github.com/yourusername/hyprdots.git
   cd hyprdots
   ```

3. **Backup your current configs:**
   ```bash
   cp -r ~/.config ~/.config-backup
   ```

4. **Deploy with stow:**
   ```bash
   # Everything at once
   stow */
   
   # Or individual packages
   stow hyprland waybar wofi kitty zsh
   ```

5. **Make scripts executable:**
   ```bash
   chmod +x ~/.local/bin/*
   ```

## Usage

**Add new configs:**
```bash
mkdir newapp
mkdir -p newapp/.config/newapp
# Add your config files
stow newapp
```

**Remove configs:**
```bash
stow -D packagename
```

**Update configs:**
Just edit the files in this repo - they're symlinked to your system.

## Structure

```
hyprdots/
├── hyprland/     # Hyprland config
├── waybar/       # Status bar
├── wofi/         # Launcher
├── kitty/        # Terminal
├── zsh/          # Shell
├── mako/         # Notifications  
├── ranger/       # File manager
├── neovim/       # Text editor
├── gtk/          # GTK themes
└── system/       # Scripts
```

## Key bindings

- `Super + Enter` - Terminal
- `Super + D` - App launcher
- `Super + Q` - Close window
- `Super + 1-9` - Switch workspace

## Notes

- Restart applications after stowing to load new configs
- Edit files in this repo, not in ~/.config (they're symlinks)
- Use `stow -n` to preview changes before applying
