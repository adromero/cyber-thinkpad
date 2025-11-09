"""
Audit logging for ThinkPad Cyberpunk privilege operations
Logs security-sensitive operations to a local audit log
"""

import os
from pathlib import Path
from datetime import datetime
from typing import Optional

# Audit log location
AUDIT_DIR = Path.home() / ".local/share/thinkpad-cyberpunk"
AUDIT_LOG = AUDIT_DIR / "audit.log"


def log_operation(
    operation: str,
    details: str,
    success: bool = True,
    user: Optional[str] = None
):
    """
    Log a privilege operation to the audit log

    Args:
        operation: Type of operation (e.g., "battery_threshold", "cpu_governor")
        details: Details of the operation (e.g., "set to 80")
        success: Whether the operation succeeded
        user: Username (defaults to current user)
    """
    # Ensure audit directory exists
    AUDIT_DIR.mkdir(parents=True, exist_ok=True)

    # Get username if not provided
    if user is None:
        user = os.getenv("USER", "unknown")

    # Format log entry
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    status = "SUCCESS" if success else "FAILED"
    log_entry = f"[{timestamp}] USER={user} OP={operation} STATUS={status} DETAILS={details}\n"

    # Append to audit log
    try:
        with open(AUDIT_LOG, 'a') as f:
            f.write(log_entry)

        # Set secure permissions on first write
        if AUDIT_LOG.stat().st_size == len(log_entry):
            os.chmod(AUDIT_LOG, 0o600)  # Only user can read/write
    except Exception as e:
        # Log to stderr for debugging, but don't break operations
        import sys
        print(f"Warning: Failed to write audit log: {e}", file=sys.stderr)


def get_recent_logs(lines: int = 50) -> str:
    """
    Get recent audit log entries

    Args:
        lines: Number of recent lines to retrieve

    Returns:
        String containing recent log entries
    """
    if not AUDIT_LOG.exists():
        return "No audit log found."

    try:
        with open(AUDIT_LOG) as f:
            all_lines = f.readlines()
            recent = all_lines[-lines:] if len(all_lines) > lines else all_lines
            return "".join(recent)
    except Exception as e:
        return f"Error reading audit log: {e}"
