# Workspace Launcher

Automatically launch and arrange applications in i3 workspaces with a single keyboard shortcut.

## Features

- **Auto-launch apps**: Press `Super+Ctrl+<num>` to launch pre-configured apps in a workspace
- **Custom layouts**: Configure split-h, split-v, tabbed, or stacking layouts
- **Position control**: Place windows left, right, top, bottom, or in custom positions
- **Easy configuration**: TUI and config file for managing workspace setups
- **Per-workspace settings**: Each workspace can have its own apps and layout

## Quick Start

### Using Keyboard Shortcuts

The following shortcuts are configured by default:

- `Super+Ctrl+1` - Launch Terminal workspace (2 terminals side-by-side)
- `Super+Ctrl+2` - Launch Code workspace (Cursor editor)
- `Super+Ctrl+3` - Launch Web workspace (Firefox)
- `Super+Ctrl+4` - Launch Files workspace (Nautilus)
- `Super+Ctrl+8` - Launch Game workspace (Moonlight)
- `Super+Ctrl+0` - Launch System workspace (Cyberdash monitor)

### Command Line Usage

```bash
# Launch a specific workspace
workspacelaunch 1

# List all configured workspaces
workspacelaunch --list

# Show keyboard shortcuts
workspacelaunch --shortcuts
```

## Configuration

### Security Considerations

**⚠️ IMPORTANT SECURITY NOTE:**

The workspace launcher executes commands from the configuration file (`~/.config/thinkpad-cyberpunk/workspaces.json`). Only add commands you trust to this configuration file.

- **Do not edit the config file with untrusted input**
- **Do not share your config file without reviewing its contents first**
- **Only configure applications you've verified are safe to run**

The launcher uses `shlex.split()` for secure command parsing, but you should still be cautious about what commands you add to your configuration.

### Using the TUI Configurator

Press `Super+Shift+W` or run:

```bash
workspaceconfig
```

The TUI allows you to:
- Add/remove applications for each workspace
- Set window positions (left, right, top, bottom, etc.)
- Configure workspace layouts
- Manage keyboard shortcuts

**TUI Controls:**
- `↑/↓` - Navigate workspaces
- `Enter` - Edit selected workspace
- `a` - Add app to selected workspace
- `d` - Delete app from workspace
- `s` - Edit keyboard shortcuts
- `q` - Quit and save

### Manual Configuration

Edit the config file directly:

```bash
nano ~/.config/thinkpad-cyberpunk/workspaces.json
```

Or use your preferred editor:

```bash
workspaceconfig --edit
```

## Configuration Schema

```json
{
  "workspaces": {
    "1": {
      "name": "TERM",
      "layout": "split-h",
      "apps": [
        {
          "command": "kitty",
          "position": "left"
        },
        {
          "command": "kitty",
          "position": "right-top"
        }
      ]
    },
    "2": {
      "name": "CODE",
      "apps": [
        {
          "command": "cursor"
        }
      ]
    }
  },
  "shortcuts": {
    "Mod4+Ctrl+1": "1",
    "Mod4+Ctrl+2": "2"
  }
}
```

### Layout Options

- `default` - No specific layout
- `split-h` - Horizontal split (side-by-side)
- `split-v` - Vertical split (stacked)
- `tabbed` - Tabbed layout
- `stacking` - Stacking layout

### Position Options

- `default` - No specific positioning
- `left` - Move window to left
- `right` - Move window to right
- `top` / `up` - Move window up
- `bottom` / `down` - Move window down
- `right-top` - Move to right, then create vertical split
- `right-bottom` - Move to right, split vertically, move down

## Examples

### Terminal Workspace with 3 Panes

```json
{
  "name": "TERM",
  "layout": "split-h",
  "apps": [
    {
      "command": "kitty",
      "position": "left"
    },
    {
      "command": "kitty -e htop",
      "position": "right-top"
    },
    {
      "command": "kitty -e watch -n 1 'date'",
      "position": "right-bottom"
    }
  ]
}
```

### Development Workspace

```json
{
  "name": "DEV",
  "layout": "split-h",
  "apps": [
    {
      "command": "cursor",
      "position": "left"
    },
    {
      "command": "kitty",
      "position": "right"
    }
  ]
}
```

### Media Workspace

```json
{
  "name": "MEDIA",
  "layout": "default",
  "apps": [
    {
      "command": "spotify"
    }
  ]
}
```

## Keyboard Shortcut Format

Shortcuts use i3 key modifier syntax:

- `Mod4` - Super/Windows key
- `Mod1` - Alt key
- `Ctrl` - Control key
- `Shift` - Shift key

Examples:
- `Mod4+Ctrl+1` - Super + Ctrl + 1
- `Mod4+Shift+w` - Super + Shift + W
- `Mod1+Ctrl+t` - Alt + Ctrl + T

## Tips

1. **Test commands first**: Make sure your app commands work from the terminal before adding them to the config
2. **Timing**: Some apps take longer to launch. The launcher waits 0.5s between launching apps
3. **Window positioning**: Position commands work best with tiling windows, not floating
4. **Layout + Position**: Combine layout and position settings for complex arrangements
5. **Backup config**: Your config is at `~/.config/thinkpad-cyberpunk/workspaces.json`

## Troubleshooting

### App doesn't launch

- Verify the command works in terminal: `kitty -e your-command`
- Check if the app is installed: `which app-name`
- Look at i3 logs: `journalctl -b | grep i3`

### Windows in wrong position

- Try adjusting the `layout` setting
- Experiment with different `position` values
- Some apps ignore window positioning (check if they're floating)

### Shortcut doesn't work

- Verify the shortcut in config matches i3 syntax
- Check for conflicts: `grep bindsym ~/.config/i3/config`
- Reload i3: `Super+Shift+R`

## Integration with i3 Config

The workspace launcher integrates with your i3 config at:
`rice/rice-configs/i3/config`

Keybindings are defined around line 208-221.

To update keybindings after changing shortcuts:
1. Edit shortcuts in `~/.config/thinkpad-cyberpunk/workspaces.json`
2. Update corresponding bindings in i3 config
3. Reload i3: `Super+Shift+R`

## Advanced Usage

### Launch on i3 Startup

Add to your i3 config:

```
exec --no-startup-id workspacelaunch 1
exec --no-startup-id workspacelaunch 10
```

### Script Integration

```bash
#!/bin/bash
# Launch development environment
workspacelaunch 2  # Code workspace
workspacelaunch 1  # Terminal workspace
workspacelaunch 3  # Browser workspace
```

### Custom Launcher Scripts

Create workspace-specific launchers:

```bash
#!/bin/bash
# ~/bin/launch-dev
workspacelaunch 2
sleep 2
i3-msg 'workspace "2:  CODE"'
```

## Files

- **Launcher**: `workspacelaunch` (in your PATH after installation)
- **Configurator**: `workspaceconfig` (in your PATH after installation)
- **Config File**: `~/.config/thinkpad-cyberpunk/workspaces.json`
- **i3 Config**: `$HOME/thinkpad-cyberpunk/rice/rice-configs/i3/config`

## See Also

- [i3 User's Guide](https://i3wm.org/docs/userguide.html)
- [CHEATSHEET.md](CHEATSHEET.md) - Keyboard shortcuts reference
- [README.md](README.md) - Main project documentation
