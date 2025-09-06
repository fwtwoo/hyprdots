#!/usr/bin/env bash
# setwall.sh - sets wallpaper, runs pywal16, updates themes
CACHE_FILE="$HOME/.cache/current_wallpaper"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
WAYBAR_COLOR_FILE="$HOME/.cache/wal/colors-waybar.css"
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"

# File caching to make last applied wallpaper work
if [[ -n "$1" ]]; then
  WALL="$1"
  echo "$WALL" >"$CACHE_FILE"
elif [[ -f "$CACHE_FILE" ]]; then
  WALL=$(cat "$CACHE_FILE")
else
  WALL="$HOME/media/images/wallpaper.jpeg"
  echo "$WALL" >"$CACHE_FILE"
fi

# Processes
pkill swaybg 2>/dev/null
swaybg -i "$WALL" -m fill &
wal -i "$WALL"
pkill -USR1 mako
pywalfox update

# Config paths
TOFI_CONF="$HOME/.config/tofi/config"
MAKO_CONF="$HOME/.config/mako/config"

# Read pywal json
PYWAL_JSON="$HOME/.cache/wal/colors.json"
if [[ -f "$PYWAL_JSON" ]]; then
  BG=$(jq -r '.special.background' "$PYWAL_JSON")
  FG=$(jq -r '.special.foreground' "$PYWAL_JSON")
  ACCENT=$(jq -r '.colors.color4' "$PYWAL_JSON")
  SEL_BG=$(jq -r '.colors.color0' "$PYWAL_JSON")

  # Patch tofi config
  sed -i "s|^\(background-color\s*=\s*\).*|\1$BG|" "$TOFI_CONF"
  sed -i "s|^\(prompt-background\s*=\s*\).*|\1$BG|" "$TOFI_CONF"
  sed -i "s|^\(prompt-color\s*=\s*\).*|\1$FG|" "$TOFI_CONF"
  sed -i "s|^\(text-color\s*=\s*\).*|\1$FG|" "$TOFI_CONF"
  sed -i "s|^\(default-result-color\s*=\s*\).*|\1$FG|" "$TOFI_CONF"
  sed -i "s|^\(selection-background\s*=\s*\).*|\1$SEL_BG|" "$TOFI_CONF"
  sed -i "s|^\(selection-color\s*=\s*\).*|\1$FG|" "$TOFI_CONF"
  sed -i "s|^\(border-color\s*=\s*\).*|\1$ACCENT|" "$TOFI_CONF"
  sed -i "s|^\(selection-match-color\s*=\s*\).*|\1$ACCENT|" "$TOFI_CONF"

  # Path mako config
  sed -i "s|^\(background-color\s*=\s*\).*|\1$BG|" "$MAKO_CONF"
  sed -i "s|^\(text-color\s*=\s*\).*|\1$FG|" "$MAKO_CONF"
  sed -i "s|^\(border-color\s*=\s*\).*|\1$ACCENT|" "$MAKO_CONF"

  # Convert hex colors to rgba for hyprlock
  # Remove # and convert to decimal
  BG_HEX=${BG#\#}
  FG_HEX=${FG#\#}
  ACCENT_HEX=${ACCENT#\#}

  BG_R=$(printf "%d" 0x${BG_HEX:0:2})
  BG_G=$(printf "%d" 0x${BG_HEX:2:2})
  BG_B=$(printf "%d" 0x${BG_HEX:4:2})

  FG_R=$(printf "%d" 0x${FG_HEX:0:2})
  FG_G=$(printf "%d" 0x${FG_HEX:2:2})
  FG_B=$(printf "%d" 0x${FG_HEX:4:2})

  ACCENT_R=$(printf "%d" 0x${ACCENT_HEX:0:2})
  ACCENT_G=$(printf "%d" 0x${ACCENT_HEX:2:2})
  ACCENT_B=$(printf "%d" 0x${ACCENT_HEX:4:2})

  BG_RGBA="rgba($BG_R, $BG_G, $BG_B, 0.8)"
  FG_RGBA="rgba($FG_R, $FG_G, $FG_B, 0.8)"
  ACCENT_RGBA="rgba($ACCENT_R, $ACCENT_G, $ACCENT_B, 0.8)"
  FONT_RGBA="rgba(200, 200, 200, 0.8)"

  # Generate hyprlock config with current colors and wallpaper
  cat >"$HYPRLOCK_CONF" <<EOF
background {
    monitor =
    path = $WALL
    blur_passes = 5
    blur_size = 1
}

input-field {
    monitor =
    size = 14%, 4%
    outline_thickness = 5
    inner_color = $BG_RGBA
    outer_color = $ACCENT_RGBA
    check_color = $ACCENT_RGBA
    fail_color = $ACCENT_RGBA
    font_color = $FONT_RGBA
    fade_on_empty = false
    rounding = 25
    dots_size = 0.22
    placeholder_text = 
    fail_text = 
    position = 0, -2
    halign = center
    valign = center
}

label {
    monitor =
    text = currently logged out...
    color = $FONT_RGBA
    font_size = 15
    font_family = JetBrainsMono Nerd Font Mono
    position = 0, 55
    halign = center
    valign = center
}
EOF

fi

# Waybar file
if [[ -f "$WAYBAR_COLOR_FILE" ]]; then
  HEX=$(grep '@define-color background' "$WAYBAR_COLOR_FILE" | awk '{print $3}' | tr -d ';')
else
  echo "Error: $WAYBAR_COLOR_FILE not found."
  exit 1
fi

# Convert hex (#rrggbb) → r,g,b
R=$(printf "%d" 0x${HEX:1:2})
G=$(printf "%d" 0x${HEX:3:2})
B=$(printf "%d" 0x${HEX:5:2})
RGBA="rgba(${R}, ${G}, ${B}, 0.6)"

# Waybar replace
sed -i "/window#waybar {/,/}/ s|^\(\s*background-color:\s*\).*;|\1${RGBA};|" "$WAYBAR_STYLE"

# Reload waybar
pkill -SIGUSR2 waybar 2>/dev/null
