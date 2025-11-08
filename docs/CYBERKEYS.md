# cyberkeys - Interactive Keybindings Reference

A cyberpunk-themed keybindings reference tool that displays all i3 keyboard shortcuts in an easy-to-read format.

## Features

- Beautiful cyberpunk-themed display
- Organized by category (Essential, Window Management, Layout, etc.)
- Multiple display modes: rofi menu, terminal, or notification
- Integrated into polybar for one-click access
- **Interactive execution** - select a keybinding and press Enter to run it
- Comprehensive list of all Super+ keybindings
- Uses xdotool for seamless keybinding simulation

## Usage

### From Polybar

Click the keyboard icon (⌨) in your polybar (to the right of the volume widget) to open an interactive rofi menu with all keybindings.

### From Terminal

```bash
# Display in rofi menu (default)
cyberkeys

# Display in terminal with colors
cyberkeys --terminal
cyberkeys -t

# Display as a notification
cyberkeys --notify
cyberkeys -n

# Display in rofi menu explicitly
cyberkeys --rofi
cyberkeys -r
```

## Keybinding Categories

### Essential
Core shortcuts you'll use most often:
- `Super+Enter` - Open Terminal
- `Super+D` - App Launcher
- `Super+Shift+Q` - Kill Window
- `Super+Escape` - Lock Screen

### Window Management
Navigate and manage windows:
- `Super+H/J/K/L` - Vim-style navigation
- `Super+Arrows` - Arrow key navigation
- `Super+Shift+H/J/K/L` - Move windows
- `Super+F` - Fullscreen toggle
- `Super+R` - Resize mode

### Layout
Control window layouts:
- `Super+B` - Split Horizontal
- `Super+V` - Split Vertical
- `Super+S` - Stacking Layout
- `Super+W` - Tabbed Layout
- `Super+E` - Toggle Split Layout

### Workspaces
Manage your 10 cyberpunk workspaces:
- `Super+1-0` - Switch to workspace
- `Super+Shift+1-0` - Move window to workspace
- `Super+Ctrl+1-0` - Auto-launch workspace apps

### ThinkPad Tools
Access system monitoring tools:
- `Super+` (grave/backtick)` - Cyberpunk Dashboard
- `Super+B` - Battery Status
- `Super+T` - Thermal Monitor
- `Super+P` - Power Profiles
- `Super+Shift+P` - Quick Power Switcher

### System
System management shortcuts:
- `Super+Shift+C` - Reload i3 Config
- `Super+Shift+R` - Restart i3
- `Super+Shift+E` - Exit i3
- `Print` - Screenshot
- `Super+Print` - Screenshot Selection

### Power Switcher Mode
When in power switcher mode (`Super+Shift+P`):
- `1` - Max Performance
- `2` - Gaming
- `3` - Balanced
- `4` - Quiet
- `5` - Max Battery

## Display Modes

### Rofi Menu (Default)
Opens a beautiful cyberpunk-themed rofi menu with all keybindings organized by category. This is the default mode and what you get when clicking the polybar icon.

**Interactive Execution:**
When you select a keybinding and press Enter, cyberkeys will automatically execute that keybinding for you! This means you can:
1. Click the KEY button in polybar
2. Browse/search for the action you want
3. Press Enter to execute it

For example, selecting "Super+Enter → Open Terminal" will actually open a terminal.

**Pros:**
- Interactive and searchable
- Easy to browse categories
- Beautiful cyberpunk styling
- Executes selected keybindings automatically
- Can be dismissed with Esc

**Usage:**
```bash
cyberkeys
# or
cyberkeys --rofi
```

### Terminal Display
Shows keybindings in your terminal with ANSI color formatting.

**Pros:**
- Works in SSH sessions
- No GUI required
- Can pipe to files or grep
- Copy-paste friendly

**Usage:**
```bash
cyberkeys --terminal
```

### Notification
Shows a compact summary as a desktop notification.

**Pros:**
- Non-intrusive
- Shows most essential shortcuts
- Auto-dismisses after 10 seconds

**Usage:**
```bash
cyberkeys --notify
```

## Customization

The keybindings are defined in the script at `/utils/bin/cyberkeys`. You can edit this file to:
- Add custom keybindings
- Modify descriptions
- Add new categories
- Change the display format

### Adding Custom Keybindings

Edit the `KEYBINDINGS` dictionary in the script:

```python
KEYBINDINGS = {
    "Custom": [
        ("Super+X", "My Custom Command"),
        ("Super+Y", "Another Command"),
    ],
    # ... existing categories
}
```

### Changing Colors

Modify the color constants:

```python
CYAN = '\033[38;5;51m'
MAGENTA = '\033[38;5;201m'
PURPLE = '\033[38;5;141m'
GREEN = '\033[38;5;46m'
YELLOW = '\033[38;5;226m'
```

## Polybar Integration

The keybindings button is integrated into polybar through the `keybindings` module:

```ini
[module/keybindings]
type = custom/text
content = "  "
content-foreground = ${colors.cyan}
click-left = /path/to/cyberkeys
format-underline = ${colors.cyan}
```

The installer automatically configures this with the correct absolute path.

## Tips

1. **Quick Reference**: Use `cyberkeys -t | less` to browse keybindings in a pager
2. **Save to File**: `cyberkeys -t > ~/keybindings.txt` to save a reference file
3. **Search**: In rofi mode, just start typing to filter keybindings
4. **Print**: `cyberkeys -t | lp` to print a physical reference

## How It Works

When you select a keybinding from the rofi menu:

1. cyberkeys parses the selected line to extract the key combination
2. Converts it to xdotool format (e.g., "Super+Enter" → "Super_L+enter")
3. Uses xdotool to simulate the key press
4. i3 receives the key press and executes the configured action

This approach ensures that whatever you've configured in your i3 config will be executed exactly as if you pressed the keys manually.

## Troubleshooting

### Keybindings Don't Execute
**Symptom**: Selecting a keybinding doesn't do anything

**Solution**: Make sure xdotool is installed:
```bash
# Ubuntu/Debian
sudo apt install xdotool

# Arch
sudo pacman -S xdotool

# Fedora
sudo dnf install xdotool
```

### Rofi Not Found
If rofi is not installed, cyberkeys will automatically fall back to terminal display.

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install rofi

# Arch
sudo pacman -S rofi

# Fedora
sudo dnf install rofi
```

### Button Not Appearing in Polybar
**Solution:**
```bash
# Re-run the installer
cd /path/to/thinkpad-cyberpunk/rice
./install-rice.sh

# Restart polybar
killall polybar && ~/.config/polybar/launch.sh &
```

### Different Keybindings
If you've customized your i3 config, the displayed keybindings may not match.

**Solution:**
Edit `/utils/bin/cyberkeys` and update the `KEYBINDINGS` dictionary to match your custom config.

## See Also

- [i3 User Guide](https://i3wm.org/docs/userguide.html)
- [Rice Guide](RICE_GUIDE.md) - Desktop customization
- [Cheatsheet](CHEATSHEET.md) - Quick reference for all tools
