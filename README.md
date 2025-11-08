# ThinkPad Cyberpunk

A cyberpunk-themed system monitoring suite and rice (desktop customization) for ThinkPad laptops running Linux.

```
╔═══════════════════════════════════════════════════════════╗
║  █▀▀ █▄█ █▄▄ █▀▀ █▀█ █▀█ █ █ █▄ █ █▄▀  ║
║  █▄▄  █  █▄█ ██▄ █▀▄ █▀▀ █▄█ █ ▀█ █ █  ║
╚═══════════════════════════════════════════════════════════╝
```

## Project Structure

This project is organized into three main directories:

### 📊 `utils/` - System Monitoring Tools
Battery management, thermal monitoring, power profiles, and cyberpunk-themed dashboards for ThinkPad laptops.

**Tools included:**
- `batctl` - Battery management and charging thresholds
- `thermctl` - Thermal monitoring
- `powerctl` - Power profile management
- `cyberdash` - Real-time monitoring dashboard
- `cyberbar` - Status bar widgets
- `cyberkeys` - Interactive keybindings reference
- `workspacelaunch` - Auto-launch apps in i3 workspaces
- `workspaceconfig` - Configure workspace app launchers

**[View full documentation →](docs/README.md)**

### 🎨 `rice/` - Desktop Customization
Cyberpunk-themed configurations for i3, polybar, rofi, kitty, and picom.

**Installation:**
```bash
cd rice
./install-rice.sh
```

**[View rice guide →](docs/RICE_GUIDE.md)**

### 📖 `docs/` - Documentation
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
git clone https://github.com/YOUR_USERNAME/thinkpad-cyberpunk.git
cd thinkpad-cyberpunk
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
batctl status     # Check battery
thermctl status   # Check thermals
cyberdash         # Launch dashboard
```

## Features

- 🔋 Battery health monitoring and charging threshold management
- 🔥 Real-time thermal monitoring with color-coded temperatures
- ⚡ Power profile switching and CPU governor control
- 💻 Beautiful cyberpunk-themed dashboard
- 📊 Status bar widgets for i3/polybar/waybar
- ⌨️ Interactive keybindings reference with one-click access and execution
- 🚀 Workspace auto-launcher with custom app configurations
- 🎨 Complete desktop rice with i3, polybar, rofi, kitty, picom
- 🌃 Neon cyberpunk color scheme throughout

## Requirements

- ThinkPad laptop running Linux
- Python 3 (no external dependencies for monitoring tools)
- For rice: i3, polybar, rofi, kitty, picom (installed by installer)

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

Built for ThinkPad enthusiasts who appreciate cyberpunk aesthetics and system control.

Stay cyber. 🌃
