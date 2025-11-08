# Recovery & Troubleshooting Guide

## Quick Recovery Options

### Option 1: Automatic Revert (Easiest)

If something breaks, run:
```bash
cd ~/Projects/thinkpad-cyberpunk
./revert.sh
```

This will:
- Show all available backups
- Let you choose which backup to restore
- Automatically restore all configs

### Option 2: Manual Backup Before Installing

Before installing, create a backup:
```bash
cd ~/Projects/thinkpad-cyberpunk
./backup.sh
```

This creates a timestamped backup with its own restore script.

### Option 3: Complete Uninstall

To remove everything and restore previous state:
```bash
cd ~/Projects/thinkpad-cyberpunk
./uninstall.sh
```

This will:
- Back up current state
- Restore previous configs
- Optionally remove the tools
- Remove PATH modifications

## Common Issues & Fixes

### i3 Won't Start / Black Screen

**Fix 1: Switch back to Cinnamon at login**
1. At login screen, click the session selector (gear icon)
2. Select "Cinnamon"
3. Log in normally

**Fix 2: TTY recovery**
1. Press `Ctrl+Alt+F2` to switch to TTY
2. Log in with your username/password
3. Run the revert script:
   ```bash
   cd ~/Projects/thinkpad-cyberpunk
   ./revert.sh
   ```
4. Press `Ctrl+Alt+F7` to return to graphical login
5. Log in with Cinnamon

### Polybar Not Showing

**Restart polybar:**
```bash
~/.config/polybar/launch.sh
```

**Check logs:**
```bash
cat /tmp/polybar.log
```

**Manual fix:**
```bash
killall polybar
polybar thinkpad-cyber &
```

### ThinkPad Modules Showing Errors

**Check if tools are accessible:**
```bash
which batctl thermctl powerctl cyberbar
```

**Re-add to PATH:**
```bash
export PATH="$HOME/thinkpad-cyberpunk/utils/bin:$PATH"
source ~/.bashrc
```

### Compositor Issues (Picom)

**Restart picom:**
```bash
killall picom
picom --config ~/.config/picom/picom.conf &
```

**Disable picom temporarily:**
```bash
killall picom
```

Edit `~/.config/i3/config` and comment out:
```bash
# exec_always --no-startup-id picom --config ~/.config/picom/picom.conf
```

Then reload i3: `Super+Shift+r`

### Terminal Won't Open

**Try alternate terminal:**
- Press `Super+d` for rofi
- Type "terminal" or "gnome-terminal"
- Or press `Ctrl+Alt+T` for default terminal

**Edit i3 config to use different terminal:**
```bash
# In TTY (Ctrl+Alt+F2):
nano ~/.config/i3/config

# Change line:
bindsym $mod+Return exec gnome-terminal
# instead of: bindsym $mod+Return exec kitty
```

### Fonts/Icons Not Showing

**Install Nerd Fonts:**
```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip
fc-cache -fv
```

**Reload i3:**
`Super+Shift+r`

### Config Errors on i3 Restart

**Check i3 config syntax:**
```bash
i3 -C
```

**View errors:**
Press `Super+Shift+r` and look at the error dialog.

**Use default config:**
```bash
cp /etc/i3/config ~/.config/i3/config
```

## Manual Recovery Steps

### Restore Individual Configs

**i3:**
```bash
# From backup
cp -r ~/.config-backup-cyberpunk-*/i3 ~/.config/

# Or use default
mkdir -p ~/.config/i3
i3-config-wizard
```

**Polybar:**
```bash
# From backup
cp -r ~/.config-backup-cyberpunk-*/polybar ~/.config/

# Or remove
rm -rf ~/.config/polybar
```

**Terminal (Kitty):**
```bash
# From backup
cp -r ~/.config-backup-cyberpunk-*/kitty ~/.config/

# Or remove (use defaults)
rm -rf ~/.config/kitty
```

### Emergency i3 Exit

If stuck in i3:
1. `Super+Shift+e` - Exit confirmation
2. Click "Yes"
3. Or `Ctrl+Alt+F2` to TTY and log out

### Reset Everything to Stock

```bash
# Remove all configs
rm -rf ~/.config/i3
rm -rf ~/.config/polybar
rm -rf ~/.config/rofi
rm -rf ~/.config/kitty
rm -rf ~/.config/picom

# Remove PATH modification
nano ~/.bashrc
# Delete line with "thinkpad-cyberpunk"

# Reboot
reboot
```

## Backup Locations

Backups are stored in:
- `~/.config-backup-cyberpunk-YYYYMMDD-HHMMSS/` - Timestamped backups
- `~/.config-backup/` - Simple manual backup from install script
- Each backup directory contains a `RESTORE.sh` script

## List All Backups

```bash
ls -lt ~/.config-backup* | grep -E "cyberpunk|backup$"
```

## Safe Testing Mode

**Test configs without switching sessions:**

```bash
# Install Xephyr (nested X server)
sudo apt install xserver-xephyr

# Run i3 in a window
Xephyr -br -ac -noreset -screen 1920x1080 :1 &
DISPLAY=:1 i3
```

This lets you test the rice without leaving Cinnamon!

## Keeping Both Setups

You can keep both Cinnamon and i3:
1. At login, switch between them using the session selector
2. Each has separate configs
3. ThinkPad tools work in both

## If Tools Stop Working

The monitoring tools (`batctl`, `thermctl`, etc.) are independent and will work regardless of desktop environment.

**Test tools directly:**
```bash
~/Projects/thinkpad-cyberpunk/utils/bin/batctl status
~/Projects/thinkpad-cyberpunk/utils/bin/thermctl status
```

**Reinstall PATH:**
```bash
echo 'export PATH="$HOME/thinkpad-cyberpunk/utils/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Nuclear Option: Fresh Start

If everything breaks:

```bash
# Remove all configs
rm -rf ~/.config/{i3,polybar,rofi,kitty,picom}

# Reinstall from scratch
cd ~/Projects/thinkpad-cyberpunk
./install-rice.sh
```

## Getting Help

### Check Logs

**i3 log:**
```bash
cat ~/.local/share/i3/log/i3log-*
```

**Polybar log:**
```bash
cat /tmp/polybar.log
```

**X server log:**
```bash
cat ~/.local/share/xorg/Xorg.0.log
```

### Backup Current Broken State (for debugging)

```bash
cd ~/Projects/thinkpad-cyberpunk
./backup.sh
# This creates a backup you can share or inspect
```

## Prevention

**Always backup before changes:**
```bash
cd ~/Projects/thinkpad-cyberpunk
./backup.sh
```

**Test in Xephyr first:**
```bash
Xephyr :1 -screen 1920x1080 &
DISPLAY=:1 i3 -c ~/.config/i3/config
```

**Keep Cinnamon as fallback:**
Don't uninstall Cinnamon - you can always switch back at login.

## Summary

**If something breaks:**
1. Switch back to Cinnamon at login (easiest)
2. Run `./revert.sh` from TTY (Ctrl+Alt+F2)
3. Run `./uninstall.sh` for complete removal
4. Manual config deletion if scripts fail

**Backups are created:**
- Automatically by `install-rice.sh`
- Manually by `backup.sh`
- Before uninstall by `uninstall.sh`

**You can always get back to working state!** 🔒
