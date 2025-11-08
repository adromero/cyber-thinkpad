#!/bin/bash
# ThinkPad Cyberpunk - Quick Revert Script

set -euo pipefail

CYAN='\033[38;5;51m'
MAGENTA='\033[38;5;201m'
GREEN='\033[38;5;46m'
RED='\033[38;5;196m'
YELLOW='\033[38;5;226m'
RESET='\033[0m'

echo -e "${MAGENTA}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  REVERT TO PREVIOUS STATE                                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Check for last backup
if [ -f ~/.thinkpad-cyberpunk-last-backup ]; then
    LAST_BACKUP=$(cat ~/.thinkpad-cyberpunk-last-backup)
    if [ -d "$LAST_BACKUP" ]; then
        echo -e "${CYAN}Found recent backup: ${GREEN}$LAST_BACKUP${RESET}\n"
        echo -e "${YELLOW}Restore this backup? (y/n)${RESET} "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            "$LAST_BACKUP/RESTORE.sh"
            exit 0
        fi
    fi
fi

# List available backups
echo -e "${CYAN}Looking for backups...${RESET}\n"

BACKUPS=($(ls -dt ~/.config-backup-cyberpunk-* 2>/dev/null))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo -e "${YELLOW}No automatic backups found.${RESET}"
    echo -e "${CYAN}Checking for manual backup directory...${RESET}\n"

    if [ -d ~/.config-backup ]; then
        echo -e "${GREEN}Found manual backup: ~/.config-backup${RESET}"
        echo -e "${YELLOW}Restore from ~/.config-backup? (y/n)${RESET} "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            # Restore from manual backup
            for dir in i3 polybar rofi kitty picom; do
                if [ -d ~/.config-backup/$dir ]; then
                    CONFIG_TARGET="${HOME}/.config/${dir}"
                    if [ -d "$CONFIG_TARGET" ] || [ -L "$CONFIG_TARGET" ]; then
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
                    cp -r ~/.config-backup/$dir ~/.config/
                    echo -e "${GREEN}✓${RESET} Restored: ~/.config/$dir"
                fi
            done
            echo -e "\n${GREEN}Restore complete!${RESET}\n"
        fi
    else
        echo -e "${RED}No backups found.${RESET}"
        echo -e "${CYAN}You can manually remove configs:${RESET}"
        echo -e "  rm -rf ~/.config/i3"
        echo -e "  rm -rf ~/.config/polybar"
        echo -e "  rm -rf ~/.config/rofi"
        echo -e "  rm -rf ~/.config/kitty"
        echo -e "  rm -rf ~/.config/picom"
    fi
    exit 1
fi

echo -e "${GREEN}Found ${#BACKUPS[@]} backup(s):${RESET}\n"

# Display backups
for i in "${!BACKUPS[@]}"; do
    backup="${BACKUPS[$i]}"
    timestamp=$(basename "$backup" | sed 's/\.config-backup-cyberpunk-//')
    size=$(du -sh "$backup" | cut -f1)
    echo -e "  ${CYAN}[$((i+1))]${RESET} $timestamp (${size})"
done

echo ""
echo -e "${YELLOW}Select backup to restore [1-${#BACKUPS[@]}], or 'q' to quit:${RESET} "
read -r choice

if [[ "$choice" == "q" ]] || [[ "$choice" == "Q" ]]; then
    echo -e "${CYAN}Cancelled.${RESET}"
    exit 0
fi

if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#BACKUPS[@]}" ]; then
    selected_backup="${BACKUPS[$((choice-1))]}"
    echo -e "${CYAN}Restoring from: ${GREEN}$selected_backup${RESET}\n"

    if [ -f "$selected_backup/RESTORE.sh" ]; then
        "$selected_backup/RESTORE.sh"
    else
        # Manual restore if RESTORE.sh doesn't exist
        for dir in i3 polybar rofi kitty picom; do
            if [ -d "$selected_backup/$dir" ]; then
                CONFIG_TARGET="${HOME}/.config/${dir}"
                if [ -d "$CONFIG_TARGET" ] || [ -L "$CONFIG_TARGET" ]; then
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
                cp -r "$selected_backup/$dir" ~/.config/
                echo -e "${GREEN}✓${RESET} Restored: ~/.config/$dir"
            fi
        done
        echo -e "\n${GREEN}Restore complete!${RESET}\n"
    fi
else
    echo -e "${RED}Invalid selection.${RESET}"
    exit 1
fi
