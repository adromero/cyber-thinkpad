#!/bin/bash
# Polybar watchdog - monitors and restarts Polybar if it dies

while true; do
    # Check if Polybar is running
    if ! pgrep -x polybar > /dev/null; then
        # Only restart if launch.sh is not already running (avoid conflicts)
        if ! pgrep -f "polybar/launch.sh" > /dev/null; then
            echo "[$(date)] Polybar not running, restarting..."
            "$HOME/.config/polybar/launch.sh"
        else
            echo "[$(date)] Polybar launch script already running, skipping restart..."
        fi
    fi

    # Check every 5 seconds
    sleep 5
done
