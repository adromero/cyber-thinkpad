# ThinkPad Cyberpunk

A cyberpunk-themed system monitoring suite and rice (desktop customization) for ThinkPad laptops running Linux.

**Built and tested on:** ThinkPad T480
**Should work on:** Most ThinkPad models with similar ACPI interfaces (T/X/P series)

```
╔═══════════════════════════════════════════════════════════╗
║  █▀▀ █▄█ █▄▄ █▀▀ █▀█ █▀█ █ █ █▄ █ █▄▀  ║
║  █▄▄  █  █▄█ ██▄ █▀▄ █▀▀ █▄█ █ ▀█ █ █  ║
╚═══════════════════════════════════════════════════════════╝
```

## Project Structure

This project is organized into three main directories:

### `utils/` - System Monitoring Tools
Battery management, thermal monitoring, power profiles, and cyberpunk-themed dashboards for ThinkPad laptops.

**Tools included:**
- `batctl` - Battery management and charging thresholds
- `thermctl` - Thermal monitoring
- `powerctl` - Power profile management
- `fanctl` - Fan speed control (requires setup)
- `cyberdash` - Real-time monitoring dashboard
- `cyberbar` - Status bar widgets
- `cyberkeys` - Interactive keybindings reference
- `winsnap` - Interactive window layout manager
- `i3-alttab` - Windows-style Alt+Tab window switcher
- `workspacelaunch` - Auto-launch apps in i3 workspaces
- `workspaceconfig` - Configure workspace app launchers

**[View full documentation →](docs/README.md)**

### `rice/` - Desktop Customization
Cyberpunk-themed configurations for i3, polybar, rofi, kitty, and picom.

**Installation:**
```bash
cd rice
./install-rice.sh
```

**[View rice guide →](docs/RICE_GUIDE.md)**

### `docs/` - Documentation
Complete documentation for all tools, installation guides, troubleshooting, and more.

**Key docs:**
- [README.md](docs/README.md) - Full tool documentation
- [RICE_GUIDE.md](docs/RICE_GUIDE.md) - Desktop customization guide
- [CHEATSHEET.md](docs/CHEATSHEET.md) - Quick reference
- [RECOVERY.md](docs/RECOVERY.md) - Troubleshooting guide

## Installation

### Quick Install

Clone the repository and run the installer:

```bash
git clone https://github.com/adromero/cyber-thinkpad.git
cd cyber-thinkpad
./install.sh
```

### Install with Rice (Desktop Customization)

To install both the monitoring tools and the cyberpunk desktop rice:

```bash
./install.sh --with-rice
```

### Installation Options

```bash
./install.sh              # Install monitoring tools only
./install.sh --with-rice  # Install tools + desktop rice
./install.sh --help       # Show all options
```

After installation, reload your shell:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

Then try the tools:

```bash
batctl status        # Check battery
thermctl status      # Check thermals
fanctl status        # Check fan status
sudo fanctl-setup    # Enable automatic fan curve (recommended!)
cyberdash            # Launch dashboard
```

## Features

- Battery health monitoring and charging threshold management
- Real-time thermal monitoring with color-coded temperatures
- Power profile switching and CPU governor control
- **Automatic fan curve daemon** - Keeps temps safe with intelligent fan control
- Manual fan speed control for fine-tuning cooling or noise levels
- Beautiful cyberpunk-themed dashboard
- Status bar widgets for i3/polybar/waybar
- Interactive keybindings reference with one-click access and execution
- **Window management tools** - Quick window snapping and interactive layout manager
- **Alt+Tab window switcher** - Windows-style window cycling with rofi menu
- Workspace auto-launcher with custom app configurations
- Complete desktop rice with i3, polybar, rofi, kitty, picom
- Neon cyberpunk color scheme throughout

## Requirements

- **ThinkPad laptop** (built for T480, compatible with most T/X/P series models)
- Linux with `thinkpad_acpi` kernel module
- Python 3.6+ (no external dependencies for monitoring tools)
- For rice: i3, polybar, rofi, kitty, picom (auto-installed by installer)

### Compatibility Notes

This suite was developed and tested on a **ThinkPad T480** but should work on most ThinkPad models that support:
- Battery charge thresholds via `/sys/class/power_supply/BAT*/charge_control_*_threshold`
- Fan control via `/proc/acpi/ibm/fan` (requires `thinkpad_acpi` module with `fan_control=1`)
- Standard thermal zones in `/sys/class/thermal/`

**Known compatible models:** T480, T490, T14, X1 Carbon (Gen 6+), X13, P series
**May require tweaking:** Older models (pre-2018) or non-T/X/P series

## Documentation

- **[Full Tool Documentation](docs/README.md)** - Complete guide to all monitoring tools
- **[Rice Guide](docs/RICE_GUIDE.md)** - Desktop customization walkthrough
- **[Quick Reference](docs/CHEATSHEET.md)** - Command cheatsheet
- **[Troubleshooting](docs/RECOVERY.md)** - Recovery and fixes

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Credits

Built and tested on a ThinkPad T480 for ThinkPad enthusiasts who appreciate cyberpunk aesthetics and system control.

Community contributions and compatibility reports for other ThinkPad models are welcome!

Stay cyber.
