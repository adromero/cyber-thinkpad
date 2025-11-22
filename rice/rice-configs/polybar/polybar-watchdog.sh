#!/bin/bash
# Polybar watchdog - monitors and restarts Polybar if it dies or after suspend/resume

# Track last resume time
LAST_RESUME_CHECK=0

while true; do
    # Check if system resumed from suspend recently (within last 10 seconds)
    CURRENT_TIME=$(date +%s)
    if [ $((CURRENT_TIME - LAST_RESUME_CHECK)) -ge 10 ]; then
        # Check journal for recent resume events
        if journalctl --user-unit=suspend.target -S "10 seconds ago" 2>/dev/null | grep -q "Reached target"; then
            echo "[$(date)] Detected resume from suspend, restarting Polybar..."
            LAST_RESUME_CHECK=$CURRENT_TIME
            if ! pgrep -f "polybar/launch.sh" > /dev/null; then
                "$HOME/.config/polybar/launch.sh"
            fi
            sleep 5
            continue
        fi

        # Also check system journal for suspend/resume
        if journalctl -b -S "10 seconds ago" 2>/dev/null | grep -qE "(Suspending system|System resumed)"; then
            echo "[$(date)] Detected system suspend/resume event, restarting Polybar..."
            LAST_RESUME_CHECK=$CURRENT_TIME
            if ! pgrep -f "polybar/launch.sh" > /dev/null; then
                "$HOME/.config/polybar/launch.sh"
            fi
            sleep 5
            continue
        fi
    fi

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
