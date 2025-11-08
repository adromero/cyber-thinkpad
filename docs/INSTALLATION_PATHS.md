# Installation Path Configuration

## Overview

The ThinkPad Cyberpunk suite now uses a configuration-based path system that automatically handles installations in any directory location. This ensures that users won't encounter path errors when installing the project.

## How It Works

### 1. Config File Generation

When you run `./install-rice.sh`, the installer automatically:
- Detects the project installation directory
- Generates a `config.env` file at the project root
- Substitutes absolute paths into configuration files

### 2. Configuration File (`config.env`)

Location: `<project-root>/config.env`

This file contains:
```bash
# Project root directory
PROJECT_ROOT=/path/to/thinkpad-cyberpunk

# Binary directory (where cyberbar, batctl, etc. are located)
BIN_DIR=${PROJECT_ROOT}/utils/bin

# Library directory (Python modules)
LIB_DIR=${PROJECT_ROOT}/utils/lib

# Rice configuration directory
RICE_DIR=${PROJECT_ROOT}/rice/rice-configs
```

### 3. Automatic Path Substitution

The installer automatically updates configuration files with absolute paths:

**Polybar Config** (`~/.config/polybar/config.ini`):
- Replaces `cyberbar battery` with `/absolute/path/to/utils/bin/cyberbar battery`
- Replaces all utility command paths with absolute paths
- This ensures polybar can find the scripts regardless of PATH settings

**Shell RC Files** (`.bashrc`, `.zshrc`):
- Adds the `utils/bin` directory to your PATH
- Uses the detected installation directory

## For Users

When you install ThinkPad Cyberpunk:

1. Clone or download to any directory:
   ```bash
   git clone https://github.com/yourusername/thinkpad-cyberpunk.git
   cd thinkpad-cyberpunk/rice
   ```

2. Run the installer:
   ```bash
   ./install-rice.sh
   ```

3. The installer handles all path configuration automatically!

## For Developers

If you're adding new scripts or utilities:

1. **New Utility Scripts**: Place them in `utils/bin/`
2. **New Polybar Modules**: Update the installer's `sed` command to include your script
3. **Config Reading**: Source `config.env` in scripts that need to find other project files

### Example: Reading Config in a Script

```bash
#!/bin/bash
# Load project configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PROJECT_ROOT/config.env"

# Now you can use: $BIN_DIR, $LIB_DIR, etc.
"$BIN_DIR/cyberbar" battery
```

## Troubleshooting

### Polybar Can't Find Scripts

**Symptom**: Missing system monitoring icons in polybar

**Solution**: Re-run the installer:
```bash
cd /path/to/thinkpad-cyberpunk/rice
./install-rice.sh
```

This regenerates all configs with the correct paths.

### Scripts Not in PATH

**Symptom**: Can't run `batctl`, `cyberbar`, etc. from terminal

**Solution**:
1. Check if PATH was added to your shell RC file:
   ```bash
   grep "thinkpad-cyberpunk" ~/.bashrc
   ```

2. If missing, add manually:
   ```bash
   echo 'export PATH="/path/to/thinkpad-cyberpunk/utils/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

### Moved Project Directory

**Symptom**: Everything broke after moving the project folder

**Solution**: Re-run the installer from the new location:
```bash
cd /new/path/thinkpad-cyberpunk/rice
./install-rice.sh
```

## Technical Details

### Why Absolute Paths?

Polybar (and other desktop components) don't inherit the user's shell environment, including PATH. By using absolute paths in polybar config, we ensure:
- Scripts work immediately after installation
- No environment variable confusion
- Works across different shells (bash, zsh, fish, etc.)

### Installer Path Detection

The installer uses:
```bash
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"
```

This resolves the actual installation directory regardless of:
- Where the project is cloned
- Symlinks
- Current working directory

## Related Files

- `rice/install-rice.sh` - Main installer with path detection
- `config.env` - Generated config file (git-ignored)
- `rice/rice-configs/polybar/config.ini` - Template (uses relative commands)
- `~/.config/polybar/config.ini` - Deployed config (uses absolute paths)
