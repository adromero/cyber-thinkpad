# ThinkPad Cyberpunk Rice Guide 🌃

Complete guide to transform your ThinkPad into a cyberpunk paradise.

## The Stack

- **Window Manager:** i3-gaps (tiling WM)
- **Status Bar:** Polybar (with ThinkPad widgets)
- **Terminal:** Kitty (GPU-accelerated, ligatures)
- **Compositor:** Picom (transparency, blur, shadows)
- **Launcher:** Rofi (dmenu replacement)
- **Shell:** Your choice (configs work with any)

## Installation

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install -y \
    i3-gaps \
    polybar \
    rofi \
    picom \
    kitty \
    feh \
    scrot \
    brightnessctl \
    i3lock \
    fonts-jetbrains-mono \
    fonts-nerd-font
```

### Arch
```bash
sudo pacman -S \
    i3-gaps \
    polybar \
    rofi \
    picom \
    kitty \
    feh \
    scrot \
    brightnessctl \
    i3lock \
    ttf-jetbrains-mono-nerd
```

### Fedora
```bash
sudo dnf install -y \
    i3-gaps \
    polybar \
    rofi \
    picom \
    kitty \
    feh \
    scrot \
    brightnessctl \
    i3lock \
    jetbrains-mono-fonts
```

## Setup

### 1. Install Nerd Fonts (if not available)
```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip
fc-cache -fv
```

### 2. Deploy Configs
```bash
cd ~/Projects/thinkpad-cyberpunk

# Backup existing configs
mkdir -p ~/.config-backup
cp -r ~/.config/i3 ~/.config-backup/ 2>/dev/null || true
cp -r ~/.config/polybar ~/.config-backup/ 2>/dev/null || true
cp -r ~/.config/rofi ~/.config-backup/ 2>/dev/null || true
cp -r ~/.config/kitty ~/.config-backup/ 2>/dev/null || true
cp -r ~/.config/picom ~/.config-backup/ 2>/dev/null || true

# Deploy cyberpunk configs
mkdir -p ~/.config/{i3,polybar,rofi,kitty,picom}
cp rice-configs/i3/config ~/.config/i3/config
cp rice-configs/polybar/config.ini ~/.config/polybar/config.ini
cp rice-configs/polybar/launch.sh ~/.config/polybar/launch.sh
chmod +x ~/.config/polybar/launch.sh
cp rice-configs/rofi/cyberpunk.rasi ~/.config/rofi/cyberpunk.rasi
cp rice-configs/kitty/kitty.conf ~/.config/kitty/kitty.conf
cp rice-configs/picom/picom.conf ~/.config/picom/picom.conf
```

### 3. Get a Cyberpunk Wallpaper
```bash
mkdir -p ~/Pictures
# Download a cyberpunk wallpaper to ~/Pictures/wallpaper.jpg
# Recommended: Search for "cyberpunk neon city 1920x1080"
```

Or use wget for a quick one:
```bash
# Example (replace with your favorite)
wget -O ~/Pictures/wallpaper.jpg "https://wallpaperaccess.com/download/cyberpunk-neon-1234567"
```

### 4. Switch to i3

**Method 1: At login screen**
- Log out
- At login screen, click the session selector (gear icon)
- Choose "i3"
- Log in

**Method 2: Test first with Xephyr**
```bash
sudo apt install xserver-xephyr
Xephyr -br -ac -noreset -screen 1920x1080 :1 &
DISPLAY=:1 i3
```

## First Login to i3

When you first log in:

1. **Choose Mod key:** Press Enter to use Windows/Super key as `$mod`
2. **Generate config:** Press Enter to generate default config (we'll override it)
3. **Open terminal:** `$mod+Enter` (Super+Enter)
4. **Open launcher:** `$mod+d` (Super+d)

## Keybindings

### Essential
| Key | Action |
|-----|--------|
| `$mod+Enter` | Open terminal (Kitty) |
| `$mod+d` | Application launcher (Rofi) |
| `$mod+Shift+q` | Kill window |
| `$mod+Shift+r` | Reload i3 |
| `$mod+Shift+e` | Exit i3 |

### Navigation
| Key | Action |
|-----|--------|
| `$mod+h/j/k/l` | Focus left/down/up/right |
| `$mod+1-0` | Switch to workspace 1-10 |
| `$mod+Shift+1-0` | Move window to workspace |

### Layout
| Key | Action |
|-----|--------|
| `$mod+b` | Split horizontal |
| `$mod+v` | Split vertical |
| `$mod+f` | Fullscreen |
| `$mod+s` | Stacking layout |
| `$mod+w` | Tabbed layout |
| `$mod+e` | Toggle split layout |
| `$mod+r` | Resize mode |

### ThinkPad Specific
| Key | Action |
|-----|--------|
| `$mod+grave` | Cyberpunk dashboard |
| `$mod+b` | Battery status |
| `$mod+t` | Thermal monitor |
| `$mod+p` | Power status |
| `$mod+Shift+p` | Power profile quick switcher |
| `$mod+Escape` | Lock screen |
| `Print` | Screenshot |
| `$mod+Print` | Screenshot (select area) |

### Power Profile Quick Switcher
Press `$mod+Shift+p`, then:
- `1` - Max Performance
- `2` - Gaming
- `3` - Balanced
- `4` - Quiet
- `5` - Max Battery

## Polybar Features

The status bar shows (left to right):
- **Workspaces** - Click to switch
- **Window title** - Current window
- **Date/Time** - Center
- **ThinkPad Battery** - Click to see details
- **ThinkPad Thermal** - Click to open thermal monitor
- **ThinkPad Power** - Click to see power status
- **Memory usage**
- **CPU usage**
- **Volume** - Click to mute

## Customization

### Colors

Edit the color scheme in any config:

**i3:** `~/.config/i3/config`
```
set $primary  #ff00ff    # Change magenta
set $cyan     #00ffff    # Change cyan
# etc.
```

**Polybar:** `~/.config/polybar/config.ini`
```ini
[colors]
primary = #ff00ff
cyan = #00ffff
```

**Kitty:** `~/.config/kitty/kitty.conf`
```
foreground #00ffff
background #1a1a2e
```

### Transparency

Adjust in `~/.config/kitty/kitty.conf`:
```
background_opacity 0.95    # 0.0-1.0
```

### Gaps

Adjust in `~/.config/i3/config`:
```
gaps inner 10    # Gap between windows
gaps outer 5     # Gap from screen edge
```

### Blur Strength

Adjust in `~/.config/picom/picom.conf`:
```
blur-strength = 5;    # 1-20
```

## Workspaces

Pre-configured workspaces:
1. 󰆍 TERM - Terminals
2.  CODE - VSCode, editors
3.  WEB - Browsers
4.  FILES - File managers
5.  MEDIA - Videos, music
6.  COMM - Discord, Slack, etc.
7.  MISC - Miscellaneous
8.  GAME - Gaming
9.  MONITOR - System monitoring (cyberdash!)
10.  SYS - System tools

## Tips & Tricks

### Auto-start apps
Add to `~/.config/i3/config`:
```bash
exec --no-startup-id firefox
exec --no-startup-id discord
```

### Per-workspace assignments
Add to `~/.config/i3/config`:
```bash
assign [class="firefox"] $ws3
assign [class="code"] $ws2
```

### Floating windows
```bash
for_window [class="floating"] floating enable
for_window [title="Terminal Float"] floating enable
```

### ThinkPad LED control
The configs already set battery presets on startup. Customize in i3 config:
```bash
exec --no-startup-id sleep 5 && batctl preset longevity
```

## Troubleshooting

### Polybar not showing
```bash
# Check logs
cat /tmp/polybar.log

# Restart manually
~/.config/polybar/launch.sh
```

### Icons not showing
Install Nerd Fonts and update font cache:
```bash
fc-cache -fv
```

### ThinkPad modules not working
Ensure tools are in PATH:
```bash
export PATH="$HOME/thinkpad-cyberpunk/utils/bin:$PATH"
```

### Compositor issues
Restart picom:
```bash
killall picom
picom --config ~/.config/picom/picom.conf &
```

## Advanced Ricing

### More transparency
```bash
# Kitty
background_opacity 0.85

# Picom - adjust per-app
opacity-rule = [
    "85:class_g = 'kitty'",
];
```

### Custom glowing effects
Edit `~/.config/picom/picom.conf`:
```
shadow-color = "#ff00ff";  # Magenta glow
shadow-radius = 20;
```

### Animated wallpapers
```bash
sudo apt install xwinwrap mpv
# Use video wallpaper scripts
```

## Screenshot Your Rice

```bash
# Full screen
scrot ~/Pictures/rice-$(date +%Y%m%d-%H%M%S).png

# With delay
scrot -d 5 ~/Pictures/rice.png

# Selection
scrot -s ~/Pictures/rice.png
```

## Share Your Rice

- r/unixporn
- r/thinkpad
- Include:
  - Screenshot
  - Distro
  - WM/DE
  - Terminal
  - Color scheme
  - Wallpaper link

## Resources

- [r/unixporn](https://reddit.com/r/unixporn) - Rice inspiration
- [i3 User Guide](https://i3wm.org/docs/userguide.html)
- [Polybar Wiki](https://github.com/polybar/polybar/wiki)
- [Cyberpunk color palettes](https://colorhunt.co/palettes/cyberpunk)

---

**Ready to rice?** Log into i3 and enjoy your cyberpunk ThinkPad! 🌃⚡
