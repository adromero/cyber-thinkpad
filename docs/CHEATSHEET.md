# ThinkPad Cyberpunk - Quick Reference

## Setup
```bash
export PATH="$HOME/thinkpad-cyberpunk/utils/bin:$PATH"  # Add to current session
# Already added to ~/.bashrc for future sessions
```

## Quick Commands

### Battery
```bash
batctl status                    # Check battery health & status
sudo batctl preset longevity     # Set 40-80% (best for battery life)
sudo batctl preset travel        # Set 75-100% (max capacity)
sudo batctl set BAT0 60 80       # Custom thresholds
```

### Thermal
```bash
thermctl status                  # Current temperatures
thermctl watch                   # Real-time monitoring
thermctl alert -t 85             # Alert if temp >= 85°C
```

### Power
```bash
powerctl status                  # Current power settings
powerctl preset gaming           # Gaming mode
powerctl preset balanced         # Balanced mode
powerctl preset max-battery      # Max battery life
sudo powerctl governor performance  # Set CPU governor
```

### Dashboard
```bash
cyberdash                        # Launch full dashboard
cyberdash -i 1                   # Update every 1 second
```

### Status Bar
```bash
cyberbar                         # Simple output
cyberbar -d                      # Detailed output
cyberbar battery                 # Battery only
cyberbar thermal                 # Thermal only
cyberbar -j                      # JSON format
```

### Workspace Launcher
```bash
workspacelaunch 1                # Launch workspace 1 (Terminal)
workspacelaunch --list           # List all configured workspaces
workspacelaunch --shortcuts      # Show keyboard shortcuts
workspaceconfig                  # Configure workspaces (TUI)
workspaceconfig --edit           # Edit config in text editor
```

## Power Presets

| Preset | Use Case | Power Profile | CPU Governor |
|--------|----------|---------------|--------------|
| `max-performance` | Compilation, heavy work | performance | performance |
| `gaming` | Gaming, high performance | performance | schedutil |
| `balanced` | Daily use | balanced | schedutil |
| `quiet` | Light work, quiet | balanced | powersave |
| `max-battery` | Maximum battery life | power-saver | powersave |

## Battery Presets

| Preset | Range | Best For |
|--------|-------|----------|
| `longevity` | 40-80% | AC use, max battery health |
| `balanced` | 50-90% | Mixed use |
| `desktop` | 60-80% | Desktop replacement |
| `travel` | 75-100% | Travel, need max capacity |
| `full` | 95-100% | Always full charge |

## Common Workflows

### Start of workday
```bash
powerctl preset gaming           # High performance
batctl status                    # Check battery
```

### End of workday
```bash
powerctl preset quiet            # Quiet mode
sudo batctl preset longevity     # Battery health mode
```

### Before travel
```bash
sudo batctl preset travel        # Max capacity
powerctl preset balanced         # Balance power
```

### Thermal monitoring during heavy work
```bash
thermctl watch                   # Keep an eye on temps
```

## i3 Keyboard Shortcuts

### System Utilities
- `Super+Grave (`)` - Open Cyberdash system monitor
- `Super+B` - Battery status
- `Super+T` - Thermal monitoring
- `Super+P` - Power profile status
- `Super+Shift+P` - Power profile quick switcher
- `Super+Shift+W` - Workspace configurator

### Workspace Auto-Launch
- `Super+Ctrl+1` - Launch Terminal workspace
- `Super+Ctrl+2` - Launch Code workspace (Cursor)
- `Super+Ctrl+3` - Launch Web workspace (Firefox)
- `Super+Ctrl+4` - Launch Files workspace
- `Super+Ctrl+8` - Launch Game workspace (Moonlight)
- `Super+Ctrl+0` - Launch System workspace (Cyberdash)

## Tips

- Battery thresholds require `sudo` to change
- Battery thresholds reset on reboot (see README for persistence)
- Use `cyberdash` for a beautiful real-time overview
- Use `cyberbar` in your status bar for constant monitoring
- Run `thermctl alert` in background to warn of high temps
- Customize workspace apps with `Super+Shift+W` or `workspaceconfig`

## Color Guide

- 🟢 Green = Good/Normal
- 🟡 Yellow = Warning/Medium
- 🔴 Red = Critical/High
- 🔵 Cyan = Info/Active
- 🟣 Purple = Labels
- 🟠 Orange = Elevated

## Demo

Run the interactive demo:
```bash
~/Projects/thinkpad-cyberpunk/demo.sh
```
