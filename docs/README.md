# ThinkPad Cyberpunk System Monitor

A cyberpunk-themed system monitoring suite for ThinkPad laptops running Linux.

```
╔═══════════════════════════════════════════════════════════╗
║  █▀▀ █▄█ █▄▄ █▀▀ █▀█ █▀█ █ █ █▄ █ █▄▀  ║
║  █▄▄  █  █▄█ ██▄ █▀▄ █▀▀ █▄█ █ ▀█ █ █  ║
╚═══════════════════════════════════════════════════════════╝
```

## Features

- **Battery Management** - Monitor battery health, set charging thresholds, apply presets
- **Thermal Monitoring** - Real-time temperature tracking and cooling device status
- **Power Profiles** - Switch between performance modes and CPU governors
- **Fan Control** - Manual fan speed control for better cooling or quieter operation
- **System Dashboard** - Beautiful cyberpunk-themed TUI with real-time stats
- **Status Bar Widgets** - Generate output for i3status, polybar, waybar, etc.

## Installation

### Quick Start

```bash
# Add to PATH
echo 'export PATH="$HOME/thinkpad-cyberpunk/utils/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Dependencies

All tools are written in pure Python 3 with no external dependencies! The tools use only standard library modules.

Optional:
- `power-profiles-daemon` - For power profile management (usually pre-installed on modern distros)

## Tools

### 🎨 cyberdash - Main Dashboard

Interactive real-time monitoring dashboard with cyberpunk aesthetics.

```bash
cyberdash                    # Launch dashboard
cyberdash -i 1.0            # Update every 1 second
cyberdash --compact         # Compact mode
```

**Features:**
- Battery status with health and time estimates
- Thermal zones with color-coded temperatures
- Power profile and CPU frequency monitoring
- System load and memory usage
- Auto-refreshing display

### 🔋 batctl - Battery Control

Manage battery charging thresholds and monitor battery health.

```bash
batctl status                          # Show battery status
batctl set BAT0 40 80                 # Set thresholds (requires sudo)
batctl preset longevity               # Apply longevity preset (40-80%)
batctl preset balanced                # Apply balanced preset (50-90%)
batctl preset desktop                 # Desktop mode (60-80%)
batctl preset travel                  # Travel mode (75-100%)
batctl preset full                    # Always full (95-100%)
```

**Battery Presets:**
- `longevity` - 40-80% (best for battery health, recommended for AC use)
- `balanced` - 50-90% (good balance)
- `desktop` - 60-80% (AC-plugged desktop replacement use)
- `travel` - 75-100% (maximum capacity for travel)
- `full` - 95-100% (always charge to full)

### 🔥 thermctl - Thermal Monitor

Monitor CPU temperatures and cooling devices.

```bash
thermctl status                       # Show thermal status
thermctl watch                        # Real-time monitoring
thermctl watch -i 1.0                 # Update every 1 second
thermctl alert -t 85                  # Alert if temp >= 85°C
```

### powerctl - Power Profile Controller

Manage power profiles and CPU governors.

```bash
powerctl status                       # Show current power status
powerctl profile performance          # Set performance profile
powerctl profile balanced             # Set balanced profile
powerctl profile powersave            # Set powersave profile
powerctl governor performance         # Set CPU governor (requires sudo)
powerctl preset max-performance       # Maximum performance
powerctl preset gaming                # Gaming preset
powerctl preset balanced              # Balanced preset
powerctl preset quiet                 # Quiet operation
powerctl preset max-battery           # Maximum battery life
```

**Power Presets:**
- `max-performance` - Maximum CPU performance, high power
- `gaming` - High performance with dynamic scaling
- `balanced` - Balance between performance and efficiency
- `quiet` - Reduced performance, quieter fans
- `max-battery` - Minimum power consumption

### 🌬️ fanctl - Fan Speed Control

Control ThinkPad fan speed manually for better cooling or quieter operation.

**IMPORTANT:** Fan control must be enabled in the kernel module first. See setup instructions below.

```bash
fanctl status                         # Show fan status and setup info
fanctl list                           # List all available fan levels
sudo fanctl set auto                  # Automatic control (recommended)
sudo fanctl set 5                     # Set to level 5 (medium-high speed)
sudo fanctl set 7                     # Maximum speed
sudo fanctl set full-speed            # Full blast (emergency cooling)
fanctl watch                          # Watch fan status in real-time
```

**Fan Levels:**
- `0` - Fan off (dangerous - use with extreme caution!)
- `1-2` - Low speed (~2000-2500 RPM)
- `3-4` - Medium speed (~3000-3500 RPM)
- `5-6` - Medium-high to high speed (~4000-4500 RPM)
- `7` - Maximum speed (~5000 RPM)
- `auto` - Automatic control (recommended for normal use)
- `full-speed` - Maximum cooling, bypasses thermal protection

**Setup (one-time):**

1. Create the kernel module configuration:
```bash
sudo cp rice/system-configs/thinkpad_acpi.conf /etc/modprobe.d/
```

Or manually create `/etc/modprobe.d/thinkpad_acpi.conf` with:
```
options thinkpad_acpi fan_control=1
```

2. Reload the thinkpad_acpi module:
```bash
sudo modprobe -r thinkpad_acpi && sudo modprobe thinkpad_acpi
```

Or simply reboot your system.

3. Verify it's enabled:
```bash
fanctl status  # Should not show warning about disabled fan control
```

**WARNING:** Manual fan control can potentially damage your hardware if misused. Always monitor temperatures when using manual fan control. Setting the fan to level 0 or full-speed mode can be dangerous. Use `auto` mode for normal operation.

**Automatic Fan Curve (Recommended):**

Instead of manually setting fan speeds, you can run the fan curve daemon that automatically adjusts fan speed based on temperature:

```bash
sudo fanctl daemon              # Run in foreground (for testing)
sudo fanctl daemon -v           # Verbose mode (show all temp updates)
sudo fanctl daemon -c custom.conf  # Use custom config
```

The daemon uses a temperature-based fan curve with hysteresis to prevent rapid fan speed changes. The default balanced curve:
- 40-49°C: Auto
- 50-54°C: Level 2 (~2500 RPM)
- 55-59°C: Level 3 (~3000 RPM)
- 60-64°C: Level 4 (~3500 RPM)
- 65-69°C: Level 5 (~4000 RPM)
- 70-74°C: Level 6 (~4500 RPM)
- 75°C+: Level 7 (maximum cooling)

**Install as System Service:**

For automatic fan control on boot, use the setup script:

```bash
sudo fanctl-setup
```

This will:
1. Enable fan control in the kernel module
2. Install the fan curve daemon as a systemd service
3. Start the daemon automatically on boot

Manage the daemon service:
```bash
sudo systemctl status fancontrol   # Check status
sudo systemctl stop fancontrol     # Stop daemon
sudo systemctl restart fancontrol  # Restart daemon
journalctl -u fancontrol -f        # View logs
```

**Customize Fan Curve:**

Edit the configuration file at `/etc/thinkpad-cyberpunk/fancurve.conf`:

```bash
sudo nano /etc/thinkpad-cyberpunk/fancurve.conf
```

Adjust temperature thresholds and fan levels to your preference (conservative/balanced/aggressive curves are provided as examples). After editing, restart the daemon:

```bash
sudo systemctl restart fancontrol
```

**Manual Control Use Cases:**
- Bottom getting hot during heavy work: `sudo fanctl set 6` or `sudo fanctl set 7`
- Need quiet operation: `sudo fanctl set 2` or `sudo fanctl set 3` (monitor temps!)
- Gaming/rendering: `sudo fanctl set 7` for maximum cooling
- Normal use: Use the daemon or `sudo fanctl set auto`

### 📊 cyberbar - Status Bar Widget

Generate status bar output for window managers.

```bash
cyberbar                              # All widgets (simple)
cyberbar -d                           # All widgets (detailed)
cyberbar battery                      # Battery widget only
cyberbar thermal                      # Thermal widget only
cyberbar power                        # Power widget only
cyberbar -j                           # JSON output
```

**Example outputs:**
```
# Simple
█ 85% | ● 45°C | ⚡

# Detailed
█85% (03:45) | ● 45°C (max: 52°C) | ⚡ performance [schedutil] 2400MHz
```

**i3status integration:**
```bash
# Add to i3status config
bar {
    status_command i3status | while read line; do
        echo "$(cyberbar) | $line" || exit 1
    done
}
```

**Polybar integration:**
```ini
[module/thinkpad]
type = custom/script
exec = cyberbar -d
interval = 5
```

## Usage Examples

### Daily Workflow

```bash
# Morning: Switch to performance mode
powerctl preset max-performance

# Check battery health
batctl status

# Monitor thermals during heavy work
thermctl watch

# Evening: Switch to quiet mode
powerctl preset quiet

# Set battery to longevity mode
sudo batctl preset longevity
```

### Dashboard Monitoring

```bash
# Launch the main dashboard for monitoring
cyberdash

# Or run thermal monitoring in another terminal
thermctl watch -i 1
```

### Status Bar Integration

```bash
# Test what will appear in your status bar
cyberbar -d

# Simple output for minimal bars
cyberbar battery
```

## Advanced Usage

### Battery Threshold Persistence

Battery thresholds reset on reboot. To make them persistent:

```bash
# Create systemd service
sudo nano /etc/systemd/system/thinkpad-battery-thresholds.service
```

```ini
[Unit]
Description=ThinkPad Battery Charge Thresholds
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/batctl preset longevity
# Or use the full path: ExecStart=$HOME/thinkpad-cyberpunk/utils/bin/batctl preset longevity

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable thinkpad-battery-thresholds.service
sudo systemctl start thinkpad-battery-thresholds.service
```

### Custom Power Profiles

Modify the presets in `utils/bin/powerctl` to create your own custom profiles.

### Scripting

All tools output clean, parseable text suitable for scripts:

```bash
# Get current battery percentage
batctl status | grep -oP '\d+(?=%)'

# Check if temperature is high
TEMP=$(thermctl status | grep -oP '\d+(?=°C)' | head -1)
if [ "$TEMP" -gt 80 ]; then
    notify-send "High Temperature" "CPU: ${TEMP}°C"
fi
```

## Color Scheme

The cyberpunk theme uses these neon colors:
- 🟦 **Cyan** (#00FFFF) - Primary UI elements
- 🟪 **Magenta** (#FF00FF) - Headers and borders
- 🟣 **Purple** (#9D7CD8) - Labels
- 🟨 **Yellow** (#FFFF00) - Warnings
- 🟩 **Green** (#00FF00) - Good status
- 🟥 **Red** (#FF0000) - Critical alerts
- 🟧 **Orange** (#FFA500) - Warnings

## Troubleshooting

### Permission Denied for Battery Thresholds

Battery threshold changes require root:
```bash
sudo batctl preset longevity
```

### Power Profile Not Working

Check if power-profiles-daemon is running:
```bash
systemctl status power-profiles-daemon
```

Install if needed:
```bash
sudo apt install power-profiles-daemon  # Ubuntu/Debian
sudo dnf install power-profiles-daemon  # Fedora
```

### CPU Governor Changes Require Root

```bash
sudo powerctl governor powersave
```

### No Thermal Zones Showing

Some ThinkPads expose thermals differently. Check:
```bash
ls /sys/class/thermal/
cat /sys/class/thermal/thermal_zone*/type
```

## File Structure

```
thinkpad-cyberpunk/
├── utils/
│   ├── bin/
│   │   ├── batctl       # Battery management
│   │   ├── thermctl     # Thermal monitoring
│   │   ├── powerctl     # Power profile control
│   │   ├── cyberdash    # Main dashboard
│   │   └── cyberbar     # Status bar widgets
│   └── lib/
│       └── sysmon.py    # Core monitoring library
├── rice/
│   ├── rice-configs/    # i3, polybar, rofi, etc.
│   └── install-rice.sh  # Rice installer
└── docs/
    └── README.md        # This file
```

## License

Free to use, modify, and distribute. No warranty provided.

## Credits

Built for ThinkPad enthusiasts who appreciate cyberpunk aesthetics and system control.

Stay cyber.
