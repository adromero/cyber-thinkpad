#!/bin/bash
# ThinkPad Cyberpunk - Backup Script

set -euo pipefail

CYAN='\033[38;5;51m'
MAGENTA='\033[38;5;201m'
GREEN='\033[38;5;46m'
RED='\033[38;5;196m'
RESET='\033[0m'

BACKUP_DIR="$HOME/.config-backup-cyberpunk-$(date +%Y%m%d-%H%M%S)"

echo -e "${MAGENTA}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  BACKUP CURRENT CONFIGS                                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

mkdir -p "$BACKUP_DIR"

echo -e "${CYAN}Backing up to: ${GREEN}$BACKUP_DIR${RESET}\n"

# Backup each config directory
for dir in i3 polybar rofi kitty picom; do
    if [ -d ~/.config/$dir ]; then
        cp -r ~/.config/$dir "$BACKUP_DIR/" 2>/dev/null || true
        echo -e "${GREEN}✓${RESET} Backed up: ~/.config/$dir"
    else
        echo -e "${CYAN}○${RESET} Not found: ~/.config/$dir (skipped)"
    fi
done

# Backup bashrc if it has our PATH modification
if grep -q "thinkpad-cyberpunk" ~/.bashrc 2>/dev/null; then
    cp ~/.bashrc "$BACKUP_DIR/bashrc"
    echo -e "${GREEN}✓${RESET} Backed up: ~/.bashrc"
fi

# Create restore script
cat > "$BACKUP_DIR/RESTORE.sh" << 'RESTORE_SCRIPT'
#!/bin/bash
# Auto-generated restore script

CYAN='\033[38;5;51m'
GREEN='\033[38;5;46m'
RED='\033[38;5;196m'
MAGENTA='\033[38;5;201m'
RESET='\033[0m'

echo -e "${MAGENTA}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  RESTORE FROM BACKUP                                      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

BACKUP_DIR="$(dirname "$0")"

# Validate backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Error: Backup directory not found${RESET}"
    exit 1
fi

echo -e "${CYAN}Restoring from: ${GREEN}$BACKUP_DIR${RESET}\n"

# Restore each config
for dir in i3 polybar rofi kitty picom; do
    if [ -d "$BACKUP_DIR/$dir" ]; then
        # Validate paths before deletion
        CONFIG_TARGET="${HOME}/.config/${dir}"
        if [ -d "$CONFIG_TARGET" ] || [ -L "$CONFIG_TARGET" ]; then
            # Ensure we're deleting within .config directory
            case "$CONFIG_TARGET" in
                "${HOME}/.config/"*)
                    rm -rf "$CONFIG_TARGET"
                    ;;
                *)
                    echo -e "${RED}Error: Invalid path detected: $CONFIG_TARGET${RESET}"
                    exit 1
                    ;;
            esac
        fi
        cp -r "$BACKUP_DIR/$dir" ~/.config/
        echo -e "${GREEN}✓${RESET} Restored: ~/.config/$dir"
    fi
done

# Restore bashrc
if [ -f "$BACKUP_DIR/bashrc" ]; then
    cp "$BACKUP_DIR/bashrc" ~/.bashrc
    echo -e "${GREEN}✓${RESET} Restored: ~/.bashrc"
fi

echo -e "\n${GREEN}Restore complete!${RESET}"
echo -e "${CYAN}Log out and back in for changes to take effect.${RESET}\n"
RESTORE_SCRIPT

chmod +x "$BACKUP_DIR/RESTORE.sh"

# Wait for all file operations to complete
sync

# Generate list of backed up files
BACKED_UP_FILES=$(ls -1 "$BACKUP_DIR" | grep -v -E "RESTORE.sh|INFO.txt")

# Create info file
cat > "$BACKUP_DIR/INFO.txt" << EOF
BACKUP INFORMATION
==================

Created: $(date)
User: $USER
Hostname: $(hostname)

Backed up configs:
$BACKED_UP_FILES

To restore this backup:
  cd "$BACKUP_DIR"
  ./RESTORE.sh

Or manually:
  cp -r "$BACKUP_DIR/i3" ~/.config/
  cp -r "$BACKUP_DIR/polybar" ~/.config/
  # etc.

EOF

echo ""
echo -e "${GREEN}✓ Backup complete!${RESET}"
echo -e "${CYAN}Backup location: ${GREEN}$BACKUP_DIR${RESET}"
echo -e "${CYAN}To restore: ${GREEN}$BACKUP_DIR/RESTORE.sh${RESET}\n"

# Save last backup path for easy access
echo "$BACKUP_DIR" > ~/.thinkpad-cyberpunk-last-backup
