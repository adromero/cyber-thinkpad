#!/usr/bin/env python3
"""
ThinkPad System Monitor Library
Cyberpunk-themed hardware monitoring for ThinkPad laptops
"""

import os
import sys
import glob
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Callable, Any
from dataclasses import dataclass
from enum import Enum
from functools import wraps


def cached_with_ttl(ttl_seconds: float = 0.5):
    """
    Decorator to cache function results with a time-to-live
    Prevents excessive file system reads for monitoring operations

    Args:
        ttl_seconds: Cache lifetime in seconds (default: 0.5)
    """
    def decorator(func: Callable) -> Callable:
        cache = {}
        cache_time = {}

        @wraps(func)
        def wrapper(self, *args, **kwargs):
            # Create cache key from function name and arguments
            cache_key = (func.__name__, args, tuple(sorted(kwargs.items())))
            current_time = time.time()

            # Check if we have a valid cached result
            if cache_key in cache:
                if current_time - cache_time[cache_key] < ttl_seconds:
                    return cache[cache_key]

            # Call function and cache result
            result = func(self, *args, **kwargs)
            cache[cache_key] = result
            cache_time[cache_key] = current_time

            return result

        return wrapper
    return decorator


class PowerProfile(Enum):
    """Power profile presets"""
    PERFORMANCE = "performance"
    BALANCED = "balanced"
    POWERSAVE = "power-save"


@dataclass
class BatteryInfo:
    """Battery status information"""
    name: str
    present: bool
    status: str  # Charging, Discharging, Full
    capacity: int  # Percentage
    energy_now: int  # µWh
    energy_full: int  # µWh
    energy_full_design: int  # µWh
    power_now: int  # µW
    voltage_now: int  # µV
    charge_start_threshold: int
    charge_end_threshold: int
    cycle_count: Optional[int] = None

    @property
    def health(self) -> int:
        """Battery health percentage"""
        if self.energy_full_design == 0:
            return 0
        return int((self.energy_full / self.energy_full_design) * 100)

    @property
    def time_remaining(self) -> Optional[int]:
        """Estimated minutes remaining (discharge) or to full (charging)"""
        if self.power_now == 0:
            return None

        if self.status == "Discharging":
            hours = self.energy_now / self.power_now
        elif self.status == "Charging":
            hours = (self.energy_full - self.energy_now) / self.power_now
        else:
            return None

        return int(hours * 60)


@dataclass
class ThermalZone:
    """Thermal zone information"""
    name: str
    type: str
    temp: int  # Celsius
    trip_points: List[int]


@dataclass
class CoolingDevice:
    """Cooling device (fan) information"""
    name: str
    type: str
    cur_state: int
    max_state: int


class ThinkPadMonitor:
    """Main system monitoring class for ThinkPad laptops"""

    def __init__(self):
        self.power_supply_path = Path("/sys/class/power_supply")
        self.thermal_path = Path("/sys/class/thermal")
        self.thinkpad_acpi_path = Path("/sys/devices/platform/thinkpad_acpi")
        self.cpu_path = Path("/sys/devices/system/cpu")

    def _read_file(self, path: Path) -> Optional[str]:
        """Safely read a sysfs file"""
        try:
            return path.read_text().strip()
        except (FileNotFoundError, PermissionError):
            return None

    def _read_int(self, path: Path, default: int = 0) -> int:
        """Read integer from sysfs file"""
        content = self._read_file(path)
        if content is None:
            return default
        try:
            return int(content)
        except ValueError:
            return default

    @cached_with_ttl(ttl_seconds=1.0)
    def get_batteries(self) -> List[BatteryInfo]:
        """Get information for all batteries"""
        batteries = []

        for bat_path in sorted(self.power_supply_path.glob("BAT*")):
            name = bat_path.name

            # Check if battery is present
            present = self._read_int(bat_path / "present") == 1
            if not present:
                continue

            # Read cycle count, checking if file exists
            cycle_count_path = bat_path / "cycle_count"
            cycle_count = None
            if cycle_count_path.exists():
                cycle_count_val = self._read_int(cycle_count_path)
                # Only set to None if the file doesn't exist or is invalid
                # Zero is a valid cycle count for new batteries
                cycle_count = cycle_count_val if cycle_count_val >= 0 else None

            batteries.append(BatteryInfo(
                name=name,
                present=present,
                status=self._read_file(bat_path / "status") or "Unknown",
                capacity=self._read_int(bat_path / "capacity"),
                energy_now=self._read_int(bat_path / "energy_now"),
                energy_full=self._read_int(bat_path / "energy_full"),
                energy_full_design=self._read_int(bat_path / "energy_full_design"),
                power_now=self._read_int(bat_path / "power_now"),
                voltage_now=self._read_int(bat_path / "voltage_now"),
                charge_start_threshold=self._read_int(
                    bat_path / "charge_control_start_threshold"
                ),
                charge_end_threshold=self._read_int(
                    bat_path / "charge_control_end_threshold", 100
                ),
                cycle_count=cycle_count,
            ))

        return batteries

    def get_ac_online(self) -> bool:
        """Check if AC adapter is connected"""
        ac_path = self.power_supply_path / "AC"
        return self._read_int(ac_path / "online") == 1

    def set_battery_threshold(self, battery: str, start: int, end: int) -> bool:
        """Set battery charge thresholds (requires root)"""
        bat_path = self.power_supply_path / battery

        if not bat_path.exists():
            return False

        try:
            # Validate thresholds
            if not (0 <= start < end <= 100):
                return False

            (bat_path / "charge_control_start_threshold").write_text(str(start))
            (bat_path / "charge_control_end_threshold").write_text(str(end))
            return True
        except PermissionError:
            return False

    @cached_with_ttl(ttl_seconds=0.5)
    def get_thermal_zones(self) -> List[ThermalZone]:
        """Get all thermal zone information"""
        zones = []

        for zone_path in sorted(self.thermal_path.glob("thermal_zone*")):
            zone_type = self._read_file(zone_path / "type") or "unknown"
            temp = self._read_int(zone_path / "temp")

            # Read trip points
            trip_points = []
            for trip_file in sorted(zone_path.glob("trip_point_*_temp")):
                trip_temp = self._read_int(trip_file)
                if trip_temp > 0:
                    trip_points.append(trip_temp // 1000)

            zones.append(ThermalZone(
                name=zone_path.name,
                type=zone_type,
                temp=temp // 1000 if temp > 0 else 0,  # Convert to Celsius
                trip_points=trip_points,
            ))

        return zones

    def get_cooling_devices(self) -> List[CoolingDevice]:
        """Get cooling device (fan) information"""
        devices = []

        for dev_path in sorted(self.thermal_path.glob("cooling_device*")):
            dev_type = self._read_file(dev_path / "type") or "unknown"

            devices.append(CoolingDevice(
                name=dev_path.name,
                type=dev_type,
                cur_state=self._read_int(dev_path / "cur_state"),
                max_state=self._read_int(dev_path / "max_state"),
            ))

        return devices

    @cached_with_ttl(ttl_seconds=0.5)
    def get_cpu_freq(self) -> Dict[int, Tuple[int, int, int]]:
        """Get CPU frequency info for each core (current, min, max) in MHz"""
        import re
        freqs = {}

        # More precise pattern to match only cpu0, cpu1, etc.
        cpu_pattern = re.compile(r'^cpu(\d+)$')

        # Optimized glob pattern - matches cpu0-cpu999 while excluding cpuidle, cpufreq
        for cpu_path in sorted(list(self.cpu_path.glob("cpu[0-9]")) +
                               list(self.cpu_path.glob("cpu[0-9][0-9]")) +
                               list(self.cpu_path.glob("cpu[0-9][0-9][0-9]"))):
            # Extract CPU number from path name (e.g., "cpu0" -> 0)
            cpu_name = cpu_path.name
            match = cpu_pattern.match(cpu_name)

            if not match:
                # Skip non-CPU directories like cpuidle, cpufreq
                continue

            cpu_num = int(match.group(1))
            cpufreq_path = cpu_path / "cpufreq"

            if not cpufreq_path.exists():
                continue

            cur = self._read_int(cpufreq_path / "scaling_cur_freq") // 1000
            min_freq = self._read_int(cpufreq_path / "scaling_min_freq") // 1000
            max_freq = self._read_int(cpufreq_path / "scaling_max_freq") // 1000

            freqs[cpu_num] = (cur, min_freq, max_freq)

        return freqs

    def get_cpu_governor(self) -> Optional[str]:
        """Get current CPU frequency governor"""
        gov_path = self.cpu_path / "cpu0/cpufreq/scaling_governor"
        return self._read_file(gov_path)

    def set_cpu_governor(self, governor: str) -> bool:
        """Set CPU frequency governor (requires root)"""
        try:
            # Collect all governor paths first to ensure atomicity
            # Optimized glob pattern - matches cpu0-cpu999
            gov_paths = (list(self.cpu_path.glob("cpu[0-9]/cpufreq/scaling_governor")) +
                        list(self.cpu_path.glob("cpu[0-9][0-9]/cpufreq/scaling_governor")) +
                        list(self.cpu_path.glob("cpu[0-9][0-9][0-9]/cpufreq/scaling_governor")))
            if not gov_paths:
                return False

            # Read current values for potential rollback
            original_values = {}
            for cpu_path in gov_paths:
                original_values[cpu_path] = self._read_file(cpu_path)

            # Track which CPUs were successfully updated
            updated_cpus = []

            # Try to set all governors
            try:
                for cpu_path in gov_paths:
                    cpu_path.write_text(governor)
                    updated_cpus.append(cpu_path)
                return True
            except (PermissionError, IOError, OSError) as e:
                # Attempt rollback - only for CPUs that were updated
                rollback_failed = []
                for cpu_path in updated_cpus:
                    original = original_values.get(cpu_path)
                    if original:
                        try:
                            cpu_path.write_text(original)
                            # Verify rollback succeeded
                            if self._read_file(cpu_path) != original:
                                rollback_failed.append(cpu_path)
                        except Exception:
                            rollback_failed.append(cpu_path)

                # If rollback failed for any CPU, system is in inconsistent state
                # This is critical - warn the user
                if rollback_failed:
                    cpu_nums = [str(p).split('cpu')[1].split('/')[0] for p in rollback_failed]
                    print(f"WARNING: Failed to rollback CPU governor for CPUs: {', '.join(cpu_nums)}",
                          file=sys.stderr)
                    print(f"System may be in inconsistent state. Manual intervention may be required.",
                          file=sys.stderr)

                # Re-raise as False for PermissionError, otherwise propagate
                if isinstance(e, PermissionError):
                    return False
                return False
        except Exception:
            return False

    def get_available_governors(self) -> List[str]:
        """Get list of available CPU governors"""
        gov_path = self.cpu_path / "cpu0/cpufreq/scaling_available_governors"
        govs = self._read_file(gov_path)
        return govs.split() if govs else []

    def get_power_profile(self) -> Optional[str]:
        """Get current power profile from power-profiles-daemon"""
        try:
            import subprocess
            result = subprocess.run(
                ["powerprofilesctl", "get"],
                capture_output=True,
                text=True,
                timeout=1
            )
            return result.stdout.strip() if result.returncode == 0 else None
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return None

    def set_power_profile(self, profile: PowerProfile) -> bool:
        """Set power profile using power-profiles-daemon"""
        try:
            import subprocess
            result = subprocess.run(
                ["powerprofilesctl", "set", profile.value],
                capture_output=True,
                timeout=1
            )
            return result.returncode == 0
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return False

    @cached_with_ttl(ttl_seconds=1.0)
    def get_load_average(self) -> Tuple[float, float, float]:
        """Get system load average (1, 5, 15 minutes)"""
        try:
            return os.getloadavg()
        except OSError:
            return (0.0, 0.0, 0.0)

    @cached_with_ttl(ttl_seconds=1.0)
    def get_memory_info(self) -> Dict[str, int]:
        """Get memory information in MB

        Returns:
            Dict with memory info keys (MemTotal, MemAvailable, etc.)
            Empty dict if /proc/meminfo is unavailable or unreadable
        """
        meminfo = {}
        try:
            with open("/proc/meminfo") as f:
                for line in f:
                    parts = line.split()
                    if len(parts) >= 2:
                        key = parts[0].rstrip(":")
                        value = int(parts[1]) // 1024  # Convert to MB
                        meminfo[key] = value
        except (FileNotFoundError, PermissionError, IOError, ValueError):
            # Return empty dict on any error - caller should check if dict is empty
            pass

        return meminfo
