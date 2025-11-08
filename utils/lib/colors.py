#!/usr/bin/env python3
"""
Cyberpunk Color Palette
Shared ANSI color codes for ThinkPad Cyberpunk tools
"""


class Colors:
    """Cyberpunk color scheme using ANSI escape codes"""

    # Control codes
    RESET = "\033[0m"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    BLINK = "\033[5m"

    # Neon colors - 256 color palette
    CYAN = "\033[38;5;51m"      # Bright cyan
    MAGENTA = "\033[38;5;201m"  # Hot pink
    PURPLE = "\033[38;5;141m"   # Purple
    YELLOW = "\033[38;5;226m"   # Bright yellow
    GREEN = "\033[38;5;46m"     # Neon green
    RED = "\033[38;5;196m"      # Bright red
    ORANGE = "\033[38;5;208m"   # Orange
    BLUE = "\033[38;5;39m"      # Electric blue
    PINK = "\033[38;5;213m"     # Pink

    # Backgrounds
    BG_BLACK = "\033[40m"
    BG_DARK = "\033[48;5;233m"
