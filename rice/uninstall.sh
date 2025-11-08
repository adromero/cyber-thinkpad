#!/bin/bash
# ThinkPad Cyberpunk - Complete Uninstall Script

set -euo pipefail

CYAN='\033[38;5;51m'
MAGENTA='\033[38;5;201m'
GREEN='\033[38;5;46m'
RED='\033[38;5;196m'
YELLOW='\033[38;5;226m'
RESET='\033[0m'

echo -e "${MAGENTA}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  UNINSTALL THINKPAD CYBERPUNK                             ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${YELLOW}This will:${RESET}"
echo -e "  • Remove all cyberpunk configs"
echo -e "  • Keep your tools in ~/Projects/thinkpad-cyberpunk"
echo -e "  • Restore previous configs if available"
echo ""
echo -e "${RED}Continue? (y/n)${RESET} "
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Cancelled.${RESET}"
    exit 0
fi

echo ""

# Create a final backup before uninstalling
echo -e "${CYAN}Creating final backup...${RESET}"
FINAL_BACKUP="$HOME/.config-backup-final-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$FINAL_BACKUP"

for dir in i3 polybar rofi kitty picom; do
    if [ -d ~/.config/$dir ]; then
        cp -r ~/.config/$dir "$FINAL_BACKUP/" 2>/dev/null || true
    fi
done

echo -e "${GREEN}✓${RESET} Backup saved to: $FINAL_BACKUP\n"

# Try to restore from previous backup
BACKUPS=($(ls -dt ~/.config-backup-cyberpunk-* 2>/dev/null))

if [ ${#BACKUPS[@]} -gt 0 ]; then
    echo -e "${CYAN}Found ${#BACKUPS[@]} previous backup(s).${RESET}"
    echo -e "${YELLOW}Restore the most recent backup? (y/n)${RESET} "
    read -r restore_response

    if [[ "$restore_response" =~ ^[Yy]$ ]]; then
        LATEST_BACKUP="${BACKUPS[0]}"
        echo -e "${CYAN}Restoring from: ${GREEN}$LATEST_BACKUP${RESET}\n"

        if [ -f "$LATEST_BACKUP/RESTORE.sh" ]; then
            "$LATEST_BACKUP/RESTORE.sh"
        else
            for dir in i3 polybar rofi kitty picom; do
                if [ -d "$LATEST_BACKUP/$dir" ]; then
                    # Validate paths before deletion
                    CONFIG_TARGET="${HOME}/.config/${dir}"
                    if [ -d "$CONFIG_TARGET" ] || [ -L "$CONFIG_TARGET" ]; then
                        # Use realpath to resolve symlinks and validate
                        REAL_TARGET="$(realpath "$CONFIG_TARGET" 2>/dev/null || echo "INVALID")"
                        REAL_CONFIG_DIR="$(realpath "${HOME}/.config" 2>/dev/null || echo "INVALID")"

                        # Ensure we're deleting within .config directory
                        case "$REAL_TARGET" in
                            "$REAL_CONFIG_DIR/"*)
                                rm -rf "$CONFIG_TARGET"
                                ;;
                            *)
                                echo -e "${RED}Error: Invalid path detected: $CONFIG_TARGET${RESET}"
                                echo -e "${RED}Resolved to: $REAL_TARGET${RESET}"
                                exit 1
                                ;;
                        esac
                    fi
                    cp -r "$LATEST_BACKUP/$dir" ~/.config/
                    echo -e "${GREEN}✓${RESET} Restored: ~/.config/$dir"
                fi
            done
        fi
    else
        echo -e "${YELLOW}Removing cyberpunk configs without restoring...${RESET}\n"
        for dir in i3 polybar rofi kitty picom; do
            CONFIG_TARGET="${HOME}/.config/${dir}"
            if [ -d "$CONFIG_TARGET" ] || [ -L "$CONFIG_TARGET" ]; then
                # Use realpath to resolve symlinks and validate
                REAL_TARGET="$(realpath "$CONFIG_TARGET" 2>/dev/null || echo "INVALID")"
                REAL_CONFIG_DIR="$(realpath "${HOME}/.config" 2>/dev/null || echo "INVALID")"

                # Validate path before deletion
                case "$REAL_TARGET" in
                    "$REAL_CONFIG_DIR/"*)
                        rm -rf "$CONFIG_TARGET"
                        echo -e "${GREEN}✓${RESET} Removed: ~/.config/$dir"
                        ;;
                    *)
                        echo -e "${RED}Error: Invalid path detected: $CONFIG_TARGET${RESET}"
                        echo -e "${RED}Resolved to: $REAL_TARGET${RESET}"
                        exit 1
                        ;;
                esac
            fi
        done
    fi
elif [ -d ~/.config-backup ]; then
    echo -e "${CYAN}Found manual backup directory.${RESET}"
    echo -e "${YELLOW}Restore from ~/.config-backup? (y/n)${RESET} "
    read -r restore_response

    if [[ "$restore_response" =~ ^[Yy]$ ]]; then
        for dir in i3 polybar rofi kitty picom; do
            if [ -d ~/.config-backup/$dir ]; then
                CONFIG_TARGET="${HOME}/.config/${dir}"
                if [ -d "$CONFIG_TARGET" ] || [ -L "$CONFIG_TARGET" ]; then
                    # Use realpath to resolve symlinks and validate
                    REAL_TARGET="$(realpath "$CONFIG_TARGET" 2>/dev/null || echo "INVALID")"
                    REAL_CONFIG_DIR="$(realpath "${HOME}/.config" 2>/dev/null || echo "INVALID")"

                    case "$REAL_TARGET" in
                        "$REAL_CONFIG_DIR/"*)
                            rm -rf "$CONFIG_TARGET"
                            ;;
                        *)
                            echo -e "${RED}Error: Invalid path detected: $CONFIG_TARGET${RESET}"
                            echo -e "${RED}Resolved to: $REAL_TARGET${RESET}"
                            exit 1
                            ;;
                    esac
                fi
                cp -r ~/.config-backup/$dir ~/.config/
                echo -e "${GREEN}✓${RESET} Restored: ~/.config/$dir"
            fi
        done
    fi
else
    echo -e "${YELLOW}No previous backups found.${RESET}"
    echo -e "${YELLOW}Remove cyberpunk configs anyway? (y/n)${RESET} "
    read -r remove_response

    if [[ "$remove_response" =~ ^[Yy]$ ]]; then
        for dir in i3 polybar rofi kitty picom; do
            CONFIG_TARGET="${HOME}/.config/${dir}"
            if [ -d "$CONFIG_TARGET" ] || [ -L "$CONFIG_TARGET" ]; then
                # Use realpath to resolve symlinks and validate
                REAL_TARGET="$(realpath "$CONFIG_TARGET" 2>/dev/null || echo "INVALID")"
                REAL_CONFIG_DIR="$(realpath "${HOME}/.config" 2>/dev/null || echo "INVALID")"

                case "$REAL_TARGET" in
                    "$REAL_CONFIG_DIR/"*)
                        rm -rf "$CONFIG_TARGET"
                        echo -e "${GREEN}✓${RESET} Removed: ~/.config/$dir"
                        ;;
                    *)
                        echo -e "${RED}Error: Invalid path detected: $CONFIG_TARGET${RESET}"
                        echo -e "${RED}Resolved to: $REAL_TARGET${RESET}"
                        exit 1
                        ;;
                esac
            fi
        done
    fi
fi

# Remove PATH modification from bashrc
if grep -q "thinkpad-cyberpunk" ~/.bashrc 2>/dev/null; then
    echo ""
    echo -e "${YELLOW}Remove thinkpad-cyberpunk from PATH in ~/.bashrc? (y/n)${RESET} "
    read -r path_response

    if [[ "$path_response" =~ ^[Yy]$ ]]; then
        # Backup bashrc
        cp ~/.bashrc ~/.bashrc.backup-$(date +%Y%m%d-%H%M%S)
        # Remove the line
        sed -i '/thinkpad-cyberpunk/d' ~/.bashrc
        echo -e "${GREEN}✓${RESET} Removed from ~/.bashrc"
    fi
fi

# Ask about keeping the tools
echo ""
echo -e "${YELLOW}Keep monitoring tools in ~/Projects/thinkpad-cyberpunk? (y/n)${RESET} "
read -r keep_response

if [[ ! "$keep_response" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Remove ~/Projects/thinkpad-cyberpunk? This will delete all tools! (y/n)${RESET} "
    read -r confirm_delete

    if [[ "$confirm_delete" =~ ^[Yy]$ ]]; then
        rm -rf ~/Projects/thinkpad-cyberpunk
        echo -e "${GREEN}✓${RESET} Removed ~/Projects/thinkpad-cyberpunk"
    fi
fi

echo ""
echo -e "${MAGENTA}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  UNINSTALL COMPLETE                                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${CYAN}Summary:${RESET}"
echo -e "  • Configs backed up to: $FINAL_BACKUP"
echo -e "  • Log out and select your previous desktop environment"
echo -e "  • To reinstall: ~/Projects/thinkpad-cyberpunk/rice/install-rice.sh"
echo ""
