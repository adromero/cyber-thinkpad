#!/bin/bash

set -u

# Add cyberbar scripts to PATH (will be replaced during installation)
export PATH="__CYBER_TOOLS_PATH__:$PATH"

# Terminate already running bar instances
# Using -q to suppress error messages if polybar isn't running
killall -q polybar || true

# Wait until the processes have been shut down (with timeout)
TIMEOUT=10
COUNTER=0
while pgrep -u $UID -x polybar >/dev/null; do
    sleep 1
    COUNTER=$((COUNTER + 1))
    if [ $COUNTER -ge $TIMEOUT ]; then
        echo "Warning: Timeout waiting for polybar to terminate, forcing kill..."
        killall -9 polybar 2>/dev/null
        sleep 2
        break
    fi
done

# Extra safety: ensure no polybar instances remain
sleep 0.5

# Launch polybar
polybar thinkpad-cyber 2>&1 | tee -a /tmp/polybar.log & disown

echo "Polybar launched..."
