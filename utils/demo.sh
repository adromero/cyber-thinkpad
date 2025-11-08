#!/bin/bash
# Quick demo of all ThinkPad Cyberpunk tools

set -euo pipefail

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ThinkPad Cyberpunk System Monitor - Quick Demo         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Add to PATH for this session
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$SCRIPT_DIR/bin:$PATH"

# Check if required commands are available
REQUIRED_COMMANDS="batctl thermctl powerctl cyberbar cyberdash"
MISSING_COMMANDS=""

for cmd in $REQUIRED_COMMANDS; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING_COMMANDS="$MISSING_COMMANDS $cmd"
    fi
done

if [ -n "$MISSING_COMMANDS" ]; then
    echo "Error: The following required commands are not found:$MISSING_COMMANDS"
    echo "Please ensure they are in the bin/ directory and executable."
    exit 1
fi

echo "1. Battery Status"
echo "═════════════════"
batctl status
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "2. Thermal Status"
echo "═════════════════"
thermctl status
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "3. Power Status"
echo "═════════════════"
powerctl status
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "4. Status Bar Widget (Simple)"
echo "═════════════════════════════"
echo "Output: $(cyberbar)"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "5. Status Bar Widget (Detailed)"
echo "═══════════════════════════════"
echo "Output: $(cyberbar -d)"
echo ""
echo "Press Enter to launch the main dashboard..."
read

echo ""
echo "Launching Cyberpunk Dashboard..."
echo "(Press Ctrl+C to exit)"
sleep 2
cyberdash
