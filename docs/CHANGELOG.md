# Changelog

All notable changes to ThinkPad Cyberpunk will be documented in this file.

## [Unreleased] - Code Quality & Security Improvements

### Added
- Shared `colors.py` module in `lib/` to eliminate code duplication
- Widget layout constants in `cyberdash` for easier customization
- Path validation before all `rm -rf` operations for security
- Timeout handling in polybar launch script (10 second timeout)
- `requirements.txt` documenting Python version requirements
- `.python-version` file specifying minimum Python 3.7
- PID file tracking for cyberwidget to prevent duplicate instances
- Multi-terminal support in cyberwidget (kitty, gnome-terminal, alacritty, xterm)
- Environment variable configuration for cyberwidget dimensions and position

### Changed
- All Python tools now import Colors from shared module
- `demo.sh` now uses script-relative paths instead of hardcoded paths
- `cyberwidget` now auto-detects terminal emulator and uses correct paths
- Error handling improved - replaced bare `except:` with specific exception types
- Better comments explaining error handling in Python scripts
- Enhanced input validation in shell scripts

### Fixed
- **Critical**: Path inconsistency in `demo.sh` (was `~/thinkpad-cyberpunk`, now script-relative)
- **Critical**: Hardcoded paths in `cyberwidget` (now uses script directory)
- **Security**: Added path validation before `rm -rf` to prevent accidental deletion
- **Security**: Protected against path traversal in config restoration
- Bare except clauses in `cyberdash` now catch specific exceptions
- Better error messages in CPU frequency parsing
- Polybar launch script can now handle hung processes with timeout
- Process detection in cyberwidget now uses PID files instead of unreliable pgrep

### Security
- All `rm -rf` operations now validate paths are within `~/.config/`
- Path traversal protection in backup/restore scripts
- Proper quoting of shell variables to prevent injection
- PID file validation to prevent race conditions

## [1.0.0] - Initial Release

### Added
- ThinkPad system monitoring library (`sysmon.py`)
- Battery control tool (`batctl`)
- Thermal monitoring tool (`thermctl`)
- Power profile controller (`powerctl`)
- Status bar widget generator (`cyberbar`)
- Interactive dashboard (`cyberdash`)
- Desktop widget (`cyberwidget`)
- i3 window manager configuration
- Polybar status bar configuration
- Rofi application launcher theme
- Kitty terminal configuration
- Picom compositor configuration
- Installation script with multi-distro support
- Backup and restore functionality
- Uninstall script
- Comprehensive documentation
